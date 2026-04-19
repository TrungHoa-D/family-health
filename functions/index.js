const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

exports.checkMissedDoses = onSchedule("every 5 minutes", async (event) => {
        const now = new Date();
        // Trễ 15 phút so với scheduled_time
        const timeThreshold = new Date(now.getTime() - 15 * 60000);

        try {
            // Tìm các log PENDING và bị trễ
            const snapshot = await db
                .collection("medication_logs")
                .where("status", "==", "PENDING")
                .where("scheduled_time", "<=", timeThreshold)
                .where("alert_sent", "==", false)
                .get();

            if (snapshot.empty) {
                console.log("No delayed pending logs found.");
                return null;
            }

            for (const logDoc of snapshot.docs) {
                const logData = logDoc.data();
                const familyId = logData.family_id;

                if (!familyId) continue;

                // Lấy family info
                const familyDoc = await db.collection("family_groups").doc(familyId).get();
                if (!familyDoc.exists) continue;
                const familyData = familyDoc.data();

                // Những thành viên được theo dõi
                const membersToNotify = familyData.members || [];
                let tokens = [];

                // Lấy fcm_tokens của các thành viên này
                for (const userId of membersToNotify) {
                    const userDoc = await db.collection("users").doc(userId).get();
                    if (userDoc.exists) {
                        const userData = userDoc.data();
                        if (userData.fcm_tokens && userData.fcm_tokens.length > 0) {
                            tokens = tokens.concat(userData.fcm_tokens);
                        }
                    }
                }

                if (tokens.length > 0) {
                    const uniqueTokens = [...new Set(tokens)];

                    // Sử dụng sendEachForMulticast thay vì sendToDevice (đã bị xóa trong Admin SDK v12+)
                    const message = {
                        notification: {
                            title: "Cảnh báo lỡ liều thuốc!",
                            body: "Đã trễ hơn 15 phút, vui lòng nhắc nhở thành viên uống thuốc.",
                        },
                        data: {
                            logId: logDoc.id,
                            scheduleId: logData.schedule_id || "",
                        },
                        tokens: uniqueTokens,
                    };

                    const response = await messaging.sendEachForMulticast(message);
                    console.log(`Missed dose alert sent. Success: ${response.successCount}, Failure: ${response.failureCount}`);

                    // Xóa token hết hạn
                    if (response.failureCount > 0) {
                        const failedTokens = [];
                        response.responses.forEach((resp, idx) => {
                            if (!resp.success && resp.error &&
                                (resp.error.code === 'messaging/invalid-registration-token' ||
                                 resp.error.code === 'messaging/registration-token-not-registered')) {
                                failedTokens.push(uniqueTokens[idx]);
                            }
                        });
                        if (failedTokens.length > 0) {
                            console.log(`Removing ${failedTokens.length} invalid tokens`);
                        }
                    }

                    // Đánh dấu đã gửi cảnh báo để không gửi lại lần nữa
                    await logDoc.ref.update({ alert_sent: true });
                }
            }

            console.log("Completed checking missed doses.");
        } catch (error) {
            console.error("Error checking missed doses:", error);
        }

        return null;
    });

exports.onMedicalEventCreated = onDocumentCreated("medical_events/{eventId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        console.log("No data associated with the event.");
        return null;
    }

    const data = snapshot.data();
    const familyId = data.family_id;
    const title = data.title;
    const creatorId = data.creator_id;

    console.log(`Event created: title="${title}", familyId="${familyId}", creatorId="${creatorId}"`);

    if (!familyId) {
        console.log("No family_id found in event data.");
        return null;
    }

    try {
        // Lấy thông tin gia đình để biết ai cần thông báo
        const familyDoc = await db.collection("family_groups").doc(familyId).get();
        if (!familyDoc.exists) {
            console.log(`Family group ${familyId} not found.`);
            return null;
        }

        // Lấy tất cả thành viên gia đình (bao gồm cả người tham gia sự kiện)
        const familyData = familyDoc.data();
        const familyMembers = familyData.members || [];
        const participantIds = data.participant_ids || [];
        // Gộp tất cả thành viên liên quan: family members + participants + creator
        const relatedUids = [...new Set([...familyMembers, ...participantIds, creatorId].filter(Boolean))];

        console.log(`Related UIDs to notify: ${JSON.stringify(relatedUids)}`);

        let tokens = [];
        // Duyệt qua các tài khoản liên quan để lấy FCM tokens
        for (const uid of relatedUids) {
            const userDoc = await db.collection("users").doc(uid).get();
            if (userDoc.exists) {
                const userData = userDoc.data();
                if (userData.fcm_tokens && userData.fcm_tokens.length > 0) {
                    tokens = tokens.concat(userData.fcm_tokens);
                    console.log(`Found ${userData.fcm_tokens.length} token(s) for user ${uid}`);
                } else {
                    console.log(`No FCM tokens for user ${uid}`);
                }
            } else {
                console.log(`User document ${uid} not found`);
            }
        }

        if (tokens.length > 0) {
            // Loại bỏ token trùng lặp
            const uniqueTokens = [...new Set(tokens)];

            console.log(`Sending to ${uniqueTokens.length} unique token(s)`);

            // Sử dụng sendEachForMulticast (API mới thay thế sendToDevice)
            const message = {
                notification: {
                    title: "📅 Sự kiện gia đình mới",
                    body: `Sự kiện "${title}" vừa được thêm vào lịch gia đình.`,
                },
                data: {
                    eventId: event.params.eventId,
                    type: "MEDICAL_EVENT",
                    click_action: "FLUTTER_NOTIFICATION_CLICK",
                },
                tokens: uniqueTokens,
            };

            const response = await messaging.sendEachForMulticast(message);
            console.log(`Sent notification for event "${title}". Success: ${response.successCount}, Failure: ${response.failureCount}`);

            // Log chi tiết lỗi nếu có
            if (response.failureCount > 0) {
                response.responses.forEach((resp, idx) => {
                    if (!resp.success) {
                        console.error(`Failed to send to token ${uniqueTokens[idx]}: ${resp.error?.message}`);
                    }
                });
            }
        } else {
            console.log("No FCM tokens found to notify.");
        }
    } catch (error) {
        console.error("Error sending event notification:", error);
    }

    return null;
});

// --- HELPER FUNCTION ĐỂ LẤY TOKENS CỦA NHÓM LƯU ---
async function getTokensForFamily(familyId, excludeUid = null) {
    let tokens = [];
    if (!familyId) return tokens;

    const familyDoc = await db.collection("family_groups").doc(familyId).get();
    if (!familyDoc.exists) return tokens;

    const members = familyDoc.data().member_ids || [];
    const validMembers = excludeUid ? members.filter(uid => uid !== excludeUid) : members;

    for (const uid of validMembers) {
        const userDoc = await db.collection("users").doc(uid).get();
        if (userDoc.exists) {
            const userData = userDoc.data();
            if (userData.fcm_tokens && userData.fcm_tokens.length > 0) {
                tokens = tokens.concat(userData.fcm_tokens);
            }
        }
    }
    return [...new Set(tokens)];
}

// 1. SỰ KIỆN HOÀN THÀNH
exports.onMedicalEventUpdated = onDocumentUpdated("medical_events/{eventId}", async (event) => {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    // Kiểm tra nếu biến finished chuyển từ false sang true
    if (beforeData.finished === false && afterData.finished === true) {
        const familyId = afterData.family_id;
        const title = afterData.title;

        console.log(`Event finished: ${title}`);
        const tokens = await getTokensForFamily(familyId);

        if (tokens.length > 0) {
            const message = {
                notification: {
                    title: "✅ Sự kiện hoàn thành",
                    body: `Sự kiện "${title}" đã được đánh dấu hoàn thành!`,
                },
                data: {
                    eventId: event.params.eventId,
                    type: "MEDICAL_EVENT",
                    click_action: "FLUTTER_NOTIFICATION_CLICK",
                },
                tokens: tokens,
            };
            await messaging.sendEachForMulticast(message);
        }
    }
    return null;
});

// 2. CRON JOB: SỰ KIỆN BẮT ĐẦU VÀ KẾT THÚC CHƯA HOÀN THÀNH
exports.checkEventStatusUpdates = onSchedule("every 1 minutes", async (event) => {
    const now = new Date();

    try {
        // Query các event chưa bắt đầu push, và đang chưa xong
        const startQuery = await db.collection("medical_events")
            .where("finished", "==", false)
            .where("notified_start", "==", false)
            .get();

        for (const doc of startQuery.docs) {
            const data = doc.data();
            if (data.status === 'CANCELLED') continue;

            const startTime = data.start_time ? (data.start_time.toDate ? data.start_time.toDate() : new Date(data.start_time)) : null;
            
            if (startTime && startTime <= now) {
                const familyId = data.family_id;
                const title = data.title;
                
                const tokens = await getTokensForFamily(familyId);
                if (tokens.length > 0) {
                    const message = {
                        notification: {
                            title: "🟢 Sự kiện đang diễn ra",
                            body: `Sự kiện "${title}" hiện đang diễn ra.`,
                        },
                        data: {
                            eventId: doc.id,
                            type: "MEDICAL_EVENT",
                            click_action: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        tokens: tokens,
                    };
                    await messaging.sendEachForMulticast(message);
                }
                await doc.ref.update({ notified_start: true });
            }
        }

        // Query các event chưa push end, và đang chưa xong
        const endQuery = await db.collection("medical_events")
            .where("finished", "==", false)
            .where("notified_end_missed", "==", false)
            .get();

        for (const doc of endQuery.docs) {
            const data = doc.data();
            if (data.status === 'CANCELLED') continue;

            const endTime = data.end_time ? (data.end_time.toDate ? data.end_time.toDate() : new Date(data.end_time)) : null;
            
            if (endTime && endTime <= now) {
                const familyId = data.family_id;
                const title = data.title;
                
                const tokens = await getTokensForFamily(familyId);
                if (tokens.length > 0) {
                    const message = {
                        notification: {
                            title: "⚠️ Hoạt động chưa hoàn thành",
                            body: `Hoạt động "${title}" chưa hoàn thành, vui lòng kiểm tra!`,
                        },
                        data: {
                            eventId: doc.id,
                            type: "MEDICAL_EVENT",
                            click_action: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        tokens: tokens,
                    };
                    await messaging.sendEachForMulticast(message);
                }
                await doc.ref.update({ notified_end_missed: true });
            }
        }
        console.log("Cron checkEventStatusUpdates finished.");
    } catch (error) {
        console.error("Error in checkEventStatusUpdates:", error);
    }
    return null;
});

// 3. THÀNH VIÊN MỚI THÊM VÀO GIA ĐÌNH
exports.onFamilyGroupUpdated = onDocumentUpdated("family_groups/{familyId}", async (event) => {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    const beforeMembers = beforeData.member_ids || [];
    const afterMembers = afterData.member_ids || [];

    // Tính thành viên mới
    const newMembers = afterMembers.filter(uid => !beforeMembers.includes(uid));

    if (newMembers.length > 0) {
        for (const newUid of newMembers) {
            const newUserDoc = await db.collection("users").doc(newUid).get();
            const newUserName = newUserDoc.exists ? newUserDoc.data().display_name || "Thành viên mới" : "Thành viên mới";

            // Push tới mọi người trong family TRỪ member mới
            const tokens = await getTokensForFamily(event.params.familyId, newUid);

            if (tokens.length > 0) {
                const message = {
                    notification: {
                        title: "👨‍👩‍👧‍👦 Gia đình có thành viên mới",
                        body: `Chào mừng ${newUserName} đã tham gia vào gia đình!`,
                    },
                    data: {
                        type: "FAMILY_UPDATE",
                        click_action: "FLUTTER_NOTIFICATION_CLICK",
                    },
                    tokens: tokens,
                };
                await messaging.sendEachForMulticast(message);
            }
        }
    }
    return null;
});

// 4. CÓ TIN NHẮN CHAT MỚI
exports.onChatMessageCreated = onDocumentCreated("chats/{chatId}", async (event) => {
    const data = event.data.data();
    if (!data) return null;

    const familyId = data.family_id;
    const senderId = data.sender_id;
    const senderName = data.sender_name || "Thành viên gia đình";
    const messageType = data.message_type || "TEXT";
    let content = data.content || "tin nhắn mới";

    if (messageType === "IMAGE") {
        content = "đã gửi hình ảnh";
    }

    // Push tới mọi người TRỪ người gửi
    const tokens = await getTokensForFamily(familyId, senderId);

    if (tokens.length > 0) {
        const message = {
            notification: {
                title: `${senderName} đã gửi 1 tin nhắn mới vào nhóm gia đình`,
                body: content,
            },
            data: {
                type: "CHAT_MESSAGE",
                chatId: event.params.chatId,
                click_action: "FLUTTER_NOTIFICATION_CLICK",
            },
            tokens: tokens,
        };
        await messaging.sendEachForMulticast(message);
    }
    return null;
});

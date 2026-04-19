const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
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

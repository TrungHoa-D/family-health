const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

exports.checkMissedDoses = onSchedule("every 5 minutes", async (event) => {
        const now = new Date();
        // Trễ 15 phút so với scheduledTime
        const timeThreshold = new Date(now.getTime() - 15 * 60000);

        try {
            // Tìm các log PENDING và bị trễ
            const snapshot = await db
                .collection("medication_logs")
                .where("status", "==", "PENDING")
                .where("scheduledTime", "<=", timeThreshold)
                .where("alert_sent", "==", false)
                .get();

            if (snapshot.empty) {
                console.log("No delayed pending logs found.");
                return null;
            }

            for (const logDoc of snapshot.docs) {
                const logData = logDoc.data();
                const familyId = logData.familyId;

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
                    // Không gửi cho chính người bệnh
                    // if (userId === logData.patientId) continue; 

                    const userDoc = await db.collection("users").doc(userId).get();
                    if (userDoc.exists) {
                        const userData = userDoc.data();
                        if (userData.fcm_tokens && userData.fcm_tokens.length > 0) {
                            tokens = tokens.concat(userData.fcm_tokens);
                        }
                    }
                }

                if (tokens.length > 0) {
                    // Gửi Push Notification
                    const payload = {
                        notification: {
                            title: "Cảnh báo lỡ liều thuốc!",
                            body: "Đã trễ hơn 15 phút, vui lòng nhắc nhở thành viên uống thuốc.",
                        },
                        data: {
                            logId: logDoc.id,
                            scheduleId: logData.scheduleId,
                        }
                    };

                    await messaging.sendToDevice(tokens, payload);

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
    const data = event.data.data();
    const familyId = data.familyId;
    const title = data.title;
    const creatorId = data.creatorId;

    if (!familyId) {
        console.log("No familyId found in event data.");
        return null;
    }

    try {
        // Lấy thông tin gia đình để biết ai cần thông báo
        const familyDoc = await db.collection("family_groups").doc(familyId).get();
        if (!familyDoc.exists) {
            console.log(`Family group ${familyId} not found.`);
            return null;
        }
        
        const familyData = familyDoc.data();
        const memberIds = familyData.memberIds || [];

        let tokens = [];
        // Duyệt qua các thành viên để lấy FCM tokens
        for (const uid of memberIds) {
            if (uid === creatorId) continue; // Không gửi cho chính người tạo

            const userDoc = await db.collection("users").doc(uid).get();
            if (userDoc.exists) {
                const userData = userDoc.data();
                if (userData.fcm_tokens && userData.fcm_tokens.length > 0) {
                    tokens = tokens.concat(userData.fcm_tokens);
                }
            }
        }

        if (tokens.length > 0) {
            // Loại bỏ token trùng lặp
            const uniqueTokens = [...new Set(tokens)];

            const payload = {
                notification: {
                    title: "📅 Sự kiện gia đình mới",
                    body: `Sự kiện "${title}" vừa được thêm vào lịch gia đình.`,
                },
                data: {
                    eventId: event.params.eventId,
                    type: "MEDICAL_EVENT",
                    click_action: "FLUTTER_NOTIFICATION_CLICK"
                }
            };

            const response = await messaging.sendToDevice(uniqueTokens, payload);
            console.log(`Sent notification for event ${title} to ${uniqueTokens.length} devices. Success: ${response.successCount}`);
        } else {
            console.log("No FCM tokens found to notify.");
        }
    } catch (error) {
        console.error("Error sending event notification:", error);
    }

    return null;
});

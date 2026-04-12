const { onSchedule } = require("firebase-functions/v2/scheduler");
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

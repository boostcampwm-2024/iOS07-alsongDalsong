// TODO : 음악제출 API입니다.
// fireStore database의 rooms/{roomNumber} 에 room 데이터를 생성합니다.
const { FieldValue } = require('firebase-admin/firestore');
const { onRequest } = require('firebase-functions/v2/https');
const { getUserData } = require('../common/RoomHelper.js');
const admin = require('../FirebaseAdmin.js');

/**
 * 방 생성을 요청하는 API
 * @param playerId - 호스트 id
 * @returns roomNumber - 생성된 방 번호
 */

module.exports.submitMusic = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Only POST requests are accepted' });
    }

    const { music } = req.body;
    const { userId, roomNumber } = req.query;
    if (!music || !userId) {
        return res.status(400).json({ error: 'Host ID is required' });
    }

    try {
        const playerData = await getUserData(userId);
        const roomRef = admin.firestore().collection('rooms').doc(roomNumber);
        if (!playerData) {
            return res.status(404).json({ error: 'plyer Data not found' });
        }

        const answer = {
            player: playerData,
            music: music
        }
        await roomRef.update({
            answers: FieldValue.arrayUnion(answer),
        })
        res.status(200).json({ status: "success" });
    } catch (error) {
        res.status(500).json({ error: 'Failed to create room' });
    }
});

// TODO : RecordOrder 변경 API 입니다.
// fireStore database의 rooms/{roomNumber}/RecordOrder를 업데이트 합니다.

const { onRequest } = require('firebase-functions/v2/https');
const { getUserData } = require('../common/RoomHelper.js');
const admin = require('../FirebaseAdmin.js');

/**
 * RecordOrder 변경 API
 * @param roomNumber - 방 번호
 * @param playerId - 참여자 id
 * @returns playerData
 */
module.exports.changeRecordOrder = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Only POST requests are accepted' });
  }
  const { roomNumber, userId } = req.body;

  if (!roomNumber || !userId) {
    return res.status(400).json({ error: 'Room number, user ID are required' });
  }

  try {
    const roomRef = admin.firestore().collection('rooms').doc(roomNumber);
    const roomSnapshot = await roomRef.get();

    if (!roomSnapshot.exists) {
      return res.status(404).json({ error: 'Room not found' });
    }

    const roomData = roomSnapshot.data();

    if (roomData.host === userId) {
      return res.status(400).json({ error: 'is not host' });
    }

    const userData = await getUserData(userId);
    if (!userData) {
      return res.status(404).json({ error: 'User not found' });
    }

    const currentRecordOrder = roomData.recordOrder + 1

    await roomRef.update({
      recordOrder: currentRecordOrder,
    });

    res.status(200).json({ success: true });
  } catch (error) {
    console.error('modify RecordOrder error:', error);
    res.status(500).json({ error: 'Failed to modify recordOrder' });
  }
});

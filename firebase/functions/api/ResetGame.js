// TODO: 게임 리셋 요청하는 API입니다.
// rooms/{roomNumber}의 status를 초기화합니다.
// 방의 호스트가 호출했는지 검사하는 로직이 필요합니다.

const { onRequest } = require('firebase-functions/v2/https');
const admin = require('../FirebaseAdmin.js');
const { FieldValue } = require('firebase-admin/firestore');

/**
 * 게임 리셋 요청을 처리하는 HTTPS 요청.
 * @param roomNumber - 방 번호
 * @param userId - 호스트 ID
 * @returns JSON 응답
 */
module.exports.resetGame = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Only POST requests are accepted' });
  }

  const { roomNumber, userId } = req.query;
  const roomRef = admin.firestore().collection('rooms').doc(roomNumber);

  try {
    const roomSnapshot = await roomRef.get();
    if (!roomSnapshot.exists) {
      return res.status(404).json({ error: 'Room not found' });
    }

    const roomData = roomSnapshot.data();

    // 요청한 유저가 방의 호스트인지 확인
    if (roomData.host.id !== userId) {
      return res.status(403).json({ error: 'Only the host can reset the game' });
    }

    const updatedRoomData = {
      ...roomData,
      round: 0,
      status: FieldValue.delete(),
      records: [],
      answers: [],
      dueTime: FieldValue.delete(),
      selectedRecords: [],
      submits: [],
      recordOrder: FieldValue.delete(),
    };

    // Firestore에 업데이트
    await roomRef.set(updatedRoomData, { merge: true });

    return res.status(200).json({ success: true });
  } catch (error) {
    console.error('Error resetting game:', error);
    return res.status(500).json({ error: 'Failed to reset the game' });
  }
});

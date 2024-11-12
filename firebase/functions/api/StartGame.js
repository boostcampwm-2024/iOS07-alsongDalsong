// TODO: 게임 시작 요청하는 API입니다.
// mode에 따라 rooms/{roomNumber}의 status를 변경합니다.
// 모드에 따라 출제자를 선택하고, duetime을 설정합니다.
// 방의 호스트가 호출했는지 검사하는 로직이 필요합니다.

const { onRequest } = require('firebase-functions/v2/https');
const admin = require('../FirebaseAdmin.js');

/**
 * 게임을 시작 요청을 하는 HTTPS requests.
 * @param roomNumber - 방 정보
 * @param playerId - 호스트 id
 * @returns Boolean
 */
module.exports.startGame = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  const { roomNumber, userId } = req.body;
  const roomRef = admin.firestore().collection('rooms').doc(roomNumber);

  try {
    const roomSnapshot = await roomRef.get();
    if (!roomSnapshot.exists) {
      return res.status(404).json({ error: 'Room not found' });
    }

    const roomData = roomSnapshot.data();

    // 요청한 유저가 방의 호스트인지 확인
    if (roomData.host.id !== userId) {
      return res.status(403).json({ error: 'Only the host can start the game' });
    }

    if (roomData.mode === 'humming') {
      // TODO Player Order 설정
      // TODO 게임 모드에 따른 라운드 설정 및 status 변경, records 초기화
      await roomRef.update({
        status: 'humming',
        round: 1,
        records: Array.from({ length: roomData.players.length }, () => ({ data: null })),
      });

      const updatedRoomData = (await roomRef.get()).data();
      res.status(200).json(updatedRoomData);
    } else {
      res.status(400).json({ error: 'Invalid mode' });
    }
  } catch (error) {
    logger.error('Error starting game:', error);
    res.status(500).json({ error: 'Failed to start game' });
  }
});

const { onRequest } = require('firebase-functions/v2/https');
const admin = require('../FirebaseAdmin.js');

/**
 * 게임을 시작 요청을 하는 HTTPS requests.
 * @param roomNumber - 방 정보
 * @param playerId - 호스트 id
 * @returns status message
 */
module.exports.startGame = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Only POST requests are accepted' });
  }

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
      // players 배열에서 order 랜덤으로 부여
      const players = roomData.players;
      const orderPool = [...Array(players.length).keys()]; // [0, 1, 2, ..., players.length - 1]

      const shuffledOrders = shuffle(orderPool);

      const updatedPlayers = players.map((player, index) => ({
        ...player,
        order: shuffledOrders[index], // 랜덤으로 부여된 order 값
      }));

      // 현재 시간에서 1분 뒤로 설정
      const currentTime = new Date();
      const dueTime = new Date(currentTime.getTime() + 1 * 60 * 1000); // 단위가 ms임
      // TODO Player Order 설정
      // TODO 게임 모드에 따른 라운드 설정 및 status 변경, records 초기화
      await roomRef.update({
        players: updatedPlayers,
        status: 'humming',
        round: 0,
        recordOrder: 0,
        dueTime: dueTime,
      });

      res.status(200).json({ success: true });
    } else {
      res.status(400).json({ error: 'Invalid mode' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Failed to start game' });
  }
});

/**
 * 배열을 랜덤으로 섞는 유틸리티 함수
 * @param {Array} array - 섞을 배열
 * @returns {Array} - 랜덤으로 섞인 배열
 */
function shuffle(array) {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
  return array;
}

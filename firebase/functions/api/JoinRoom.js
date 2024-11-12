// TODO : 방 참여 API입니다.
// fireStore database의 rooms/{roomNumber}/players 에 player 데이터를 추가합니다.

const { onRequest } = require('firebase-functions/v2/https');
const admin = require('../FirebaseAdmin.js');

/**
 * 방 참여를 요청하는 API
 * @param roomNumber - 방 번호
 * @param playerId - 참여자 id
 * @returns playerData
 */
module.exports.joinRoom = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  res.status(200).json({ message: 'Join Room' });
});

// TODO : 방 생성 API입니다.
// fireStore database의 rooms/{roomNumber} 에 room 데이터를 생성합니다.

const { onRequest } = require('firebase-functions/v2/https');
const admin = require('../FirebaseAdmin.js');

/**
 * 방 생성을 요청하는 API
 * @param playerId - 호스트 id
 * @returns roomData
 */
module.exports.createRoom = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  res.status(200).json({ message: 'Create Room' });
});

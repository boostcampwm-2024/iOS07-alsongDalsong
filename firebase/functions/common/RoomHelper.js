const admin = require('../FirebaseAdmin.js');
const firestore = admin.firestore();

/**
 * 방 번호를 생성하는 함수.
 * @returns roomNumber
 */
function generateRoomNumber() {}

/**
 * 방 번호가 유효한지 확인하는 함수
 * @param roomNumber - 방 번호
 * @returns boolean
 */
async function invalidRoomNumber(roomNumber) {
  const roomSnapshot = await firestore.collection('rooms').where('number', '==', roomNumber).get();
  return roomSnapshot.empty;
}

/**
 * Realtime Database에 있는 Player 데이터 가져오는 함수
 * @param id - 사용자 id
 * @returns player
 */

async function getUserData(id) {
  const userSnapshot = await admin.database().ref(`/players/${id}`).once('value');
  if (!userSnapshot.exists()) return null;
  return userSnapshot.val();
}

/**
 * 방의 정원을 확인하는 함수
 * @param roomNumber - 방 번호
 * @returns boolean
 */
async function isRoomFull(roomNumber) {}

/**
 * DB 초기화 함수
 * @param roomNumber - 방 번호
 * @returns boolean
 */
async function resetRoom(roomNumber) {}

/**
 * 사용자가 호스트인지 확인하는 함수
 * @param userId - 사용자 id
 * @param roomNumber - 방 번호
 * @returns boolean
 */
async function isHost(userId, roomNumber) {}

module.exports = { generateRoomNumber, invalidRoomNumber, getUserData, isRoomFull, resetRoom, isHost };

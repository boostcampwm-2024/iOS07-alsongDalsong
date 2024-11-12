const admin = require('../FirebaseAdmin.js');
const firestore = admin.firestore();

/**
 * 승자 계산 함수
 * @returns player - 가장 높은 점수를 가진 플레이어 배열
 */
function calculateWinners() {}

/**
 * 플레이어 순서 결정 함수
 * @param mode - 게임 모드
 * @param players - 플레이어 배열
 * @returns orderedPlayers - 순서가 배분된 플레이어 배열
 */
function determinePlayerOrder(mode, players) {}

module.exports = {
  calculateWinners,
  determinePlayerOrder,
};

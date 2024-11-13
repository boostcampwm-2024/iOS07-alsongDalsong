// TODO: 문제를 제출하고, 방에 저장하는 API입니다.
// 문제는 rooms/{roomNumber}/answers 에 저장합니다.

/**
 * 제출자가 문제를 정하고 방에 저장하는 API입니다..
 * @param roomNumber - 방 정보
 * @param playerId - 제출자 id
 * @param Answer - 제출된 문제
 * @returns Boolean
 */

module.exports.submitQuestion = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  res.status(200).json({ message: 'Submit Question' });
});

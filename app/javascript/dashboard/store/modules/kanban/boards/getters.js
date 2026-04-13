export const getters = {
  getUIFlags($state) {
    return $state.uiFlags;
  },
  getAllBoards: $state => {
    return Object.values($state.records);
  },
  getBoardById: $state => id => {
    return $state.records[id];
  },
  getFavoriteBoards: $state => {
    const favoriteIds = $state.preferences?.favorite_board_ids || [];
    return Object.values($state.records).filter(board =>
      favoriteIds.includes(board.id)
    );
  },
  getPreferences: $state => {
    return $state.preferences || {};
  },
};

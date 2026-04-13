import * as types from './types';

export const mutations = {
  [types.SET_KANBAN_BOARD_UI_FLAG]($state, data) {
    $state.uiFlags = {
      ...$state.uiFlags,
      ...data,
    };
  },

  [types.CLEAR_KANBAN_BOARDS]: $state => {
    $state.records = {};
  },

  [types.SET_KANBAN_BOARDS]: ($state, data) => {
    data.forEach(board => {
      $state.records[board.id] = {
        ...($state.records[board.id] || {}),
        ...board,
      };
    });
  },

  [types.SET_KANBAN_BOARD_ITEM]: ($state, data) => {
    $state.records[data.id] = {
      ...($state.records[data.id] || {}),
      ...data,
    };
  },

  [types.EDIT_KANBAN_BOARD]: ($state, data) => {
    $state.records[data.id] = data;
  },

  [types.DELETE_KANBAN_BOARD]: ($state, boardId) => {
    delete $state.records[boardId];
  },

  [types.SET_KANBAN_PREFERENCES]: ($state, preferences) => {
    $state.preferences = preferences;
  },
};

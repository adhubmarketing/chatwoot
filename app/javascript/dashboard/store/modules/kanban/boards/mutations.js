import * as types from './types';
import Vue from 'vue';

export const mutations = {
  [types.SET_KANBAN_BOARD_UI_FLAG]($state, data) {
    $state.uiFlags = {
      ...$state.uiFlags,
      ...data,
    };
  },

  [types.CLEAR_KANBAN_BOARDS]: $state => {
    Vue.set($state, 'records', {});
  },

  [types.SET_KANBAN_BOARDS]: ($state, data) => {
    data.forEach(board => {
      Vue.set($state.records, board.id, {
        ...($state.records[board.id] || {}),
        ...board,
      });
    });
  },

  [types.SET_KANBAN_BOARD_ITEM]: ($state, data) => {
    Vue.set($state.records, data.id, {
      ...($state.records[data.id] || {}),
      ...data,
    });
  },

  [types.EDIT_KANBAN_BOARD]: ($state, data) => {
    Vue.set($state.records, data.id, data);
  },

  [types.DELETE_KANBAN_BOARD]: ($state, boardId) => {
    Vue.delete($state.records, boardId);
  },

  [types.SET_KANBAN_PREFERENCES]: ($state, preferences) => {
    $state.preferences = preferences;
  },
};

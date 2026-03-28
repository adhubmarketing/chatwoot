import * as types from './types';
import KanbanBoardsAPI from '../../../../api/kanban/boards';

export const actions = {
  get: async ({ commit }, boardId) => {
    commit(types.SET_KANBAN_BOARD_UI_FLAG, { isFetching: true });
    try {
      const response = await KanbanBoardsAPI.show(boardId);
      commit(types.SET_KANBAN_BOARD_ITEM, response.data);
      commit(types.SET_KANBAN_BOARD_UI_FLAG, { isFetching: false });
      return response.data;
    } catch (error) {
      commit(types.SET_KANBAN_BOARD_UI_FLAG, { isFetching: false });
      throw error;
    }
  },

  getAll: async ({ commit }) => {
    commit(types.SET_KANBAN_BOARD_UI_FLAG, { isFetching: true });
    try {
      const response = await KanbanBoardsAPI.get();
      const { boards, preferences } = response.data.payload;
      commit(types.SET_KANBAN_BOARDS, boards);
      commit(types.SET_KANBAN_PREFERENCES, preferences);
      commit(types.SET_KANBAN_BOARD_UI_FLAG, { isFetching: false });
      return boards;
    } catch (error) {
      commit(types.SET_KANBAN_BOARD_UI_FLAG, { isFetching: false });
      throw error;
    }
  },

  create: async ({ commit }, boardData) => {
    commit(types.SET_KANBAN_BOARD_UI_FLAG, { isCreating: true });
    try {
      const response = await KanbanBoardsAPI.create(boardData);
      commit(types.SET_KANBAN_BOARD_ITEM, response.data);
      commit(types.SET_KANBAN_BOARD_UI_FLAG, { isCreating: false });
      return response.data;
    } catch (error) {
      commit(types.SET_KANBAN_BOARD_UI_FLAG, { isCreating: false });
      throw error;
    }
  },

  update: async ({ commit }, { id, ...boardData }) => {
    commit(types.SET_KANBAN_BOARD_UI_FLAG, { isUpdating: true });
    try {
      const response = await KanbanBoardsAPI.update(id, boardData);
      commit(types.EDIT_KANBAN_BOARD, response.data);
      commit(types.SET_KANBAN_BOARD_UI_FLAG, { isUpdating: false });
      return response.data;
    } catch (error) {
      commit(types.SET_KANBAN_BOARD_UI_FLAG, { isUpdating: false });
      throw error;
    }
  },

  delete: async ({ commit }, boardId) => {
    commit(types.SET_KANBAN_BOARD_UI_FLAG, { isDeleting: true });
    try {
      await KanbanBoardsAPI.delete(boardId);
      commit(types.DELETE_KANBAN_BOARD, boardId);
      commit(types.SET_KANBAN_BOARD_UI_FLAG, { isDeleting: false });
    } catch (error) {
      commit(types.SET_KANBAN_BOARD_UI_FLAG, { isDeleting: false });
      throw error;
    }
  },

  toggleFavorite: async ({ commit }, boardId) => {
    const response = await KanbanBoardsAPI.toggleFavorite(boardId);
    // Reload preferences after toggling
    const allResponse = await KanbanBoardsAPI.get();
    commit(
      types.SET_KANBAN_PREFERENCES,
      allResponse.data.payload.preferences
    );
    return response.data;
  },

  updateAgents: async ({ commit }, { boardId, agentIds }) => {
    commit(types.SET_KANBAN_BOARD_UI_FLAG, { isUpdating: true });
    try {
      const response = await KanbanBoardsAPI.updateAgents(boardId, agentIds);
      commit(types.EDIT_KANBAN_BOARD, response.data);
      commit(types.SET_KANBAN_BOARD_UI_FLAG, { isUpdating: false });
      return response.data;
    } catch (error) {
      commit(types.SET_KANBAN_BOARD_UI_FLAG, { isUpdating: false });
      throw error;
    }
  },

  updateInboxes: async ({ commit }, { boardId, inboxIds }) => {
    commit(types.SET_KANBAN_BOARD_UI_FLAG, { isUpdating: true });
    try {
      const response = await KanbanBoardsAPI.updateInboxes(boardId, inboxIds);
      commit(types.EDIT_KANBAN_BOARD, response.data);
      commit(types.SET_KANBAN_BOARD_UI_FLAG, { isUpdating: false });
      return response.data;
    } catch (error) {
      commit(types.SET_KANBAN_BOARD_UI_FLAG, { isUpdating: false });
      throw error;
    }
  },

  getConversations: async (context, { boardId, filters }) => {
    const response = await KanbanBoardsAPI.getConversations(boardId, filters);
    return response.data.payload;
  },
};

import KanbanPreferencesAPI from '../../../../api/kanban/preferences';

const state = {
  preferences: {},
  uiFlags: {
    isUpdating: false,
  },
};

const getters = {
  getPreferences: $state => $state.preferences,
  getUIFlags: $state => $state.uiFlags,
};

const actions = {
  update: async ({ commit }, preferences) => {
    commit('SET_UI_FLAG', { isUpdating: true });
    try {
      const response = await KanbanPreferencesAPI.update(preferences);
      commit('SET_PREFERENCES', response.data.preferences);
      commit('SET_UI_FLAG', { isUpdating: false });
      return response.data.preferences;
    } catch (error) {
      commit('SET_UI_FLAG', { isUpdating: false });
      throw error;
    }
  },
};

const mutations = {
  SET_UI_FLAG: ($state, data) => {
    $state.uiFlags = { ...$state.uiFlags, ...data };
  },

  SET_PREFERENCES: ($state, preferences) => {
    $state.preferences = preferences;
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};

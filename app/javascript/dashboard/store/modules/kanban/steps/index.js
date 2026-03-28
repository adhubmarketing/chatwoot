import KanbanStepsAPI from '../../../../api/kanban/steps';

const state = {
  records: {},
  uiFlags: {
    isFetching: false,
    isCreating: false,
    isUpdating: false,
    isDeleting: false,
  },
};

const getters = {
  getUIFlags: $state => $state.uiFlags,
  getAllSteps: $state => Object.values($state.records),
  getStepById: $state => id => $state.records[id],
  getStepsByBoardId: $state => boardId => {
    return Object.values($state.records).filter(
      step => step.board_id === boardId
    );
  },
};

const actions = {
  get: async ({ commit }, stepId) => {
    commit('SET_UI_FLAG', { isFetching: true });
    try {
      const response = await KanbanStepsAPI.get(stepId);
      commit('SET_STEP', response.data);
      commit('SET_UI_FLAG', { isFetching: false });
      return response.data;
    } catch (error) {
      commit('SET_UI_FLAG', { isFetching: false });
      throw error;
    }
  },

  getAll: async ({ commit }, params) => {
    commit('SET_UI_FLAG', { isFetching: true });
    try {
      const response = await KanbanStepsAPI.index(params);
      commit('SET_STEPS', response.data.payload);
      commit('SET_UI_FLAG', { isFetching: false });
      return response.data.payload;
    } catch (error) {
      commit('SET_UI_FLAG', { isFetching: false });
      throw error;
    }
  },

  create: async ({ commit }, { boardId, stepData }) => {
    commit('SET_UI_FLAG', { isCreating: true });
    try {
      const response = await KanbanStepsAPI.create(boardId, stepData);
      commit('SET_STEP', response.data);
      commit('SET_UI_FLAG', { isCreating: false });
      return response.data;
    } catch (error) {
      commit('SET_UI_FLAG', { isCreating: false });
      throw error;
    }
  },

  update: async ({ commit }, { id, ...stepData }) => {
    commit('SET_UI_FLAG', { isUpdating: true });
    try {
      const response = await KanbanStepsAPI.update(id, stepData);
      commit('SET_STEP', response.data);
      commit('SET_UI_FLAG', { isUpdating: false });
      return response.data;
    } catch (error) {
      commit('SET_UI_FLAG', { isUpdating: false });
      throw error;
    }
  },

  delete: async ({ commit }, stepId) => {
    commit('SET_UI_FLAG', { isDeleting: true });
    try {
      await KanbanStepsAPI.delete(stepId);
      commit('DELETE_STEP', stepId);
      commit('SET_UI_FLAG', { isDeleting: false });
    } catch (error) {
      commit('SET_UI_FLAG', { isDeleting: false });
      throw error;
    }
  },

  reorderSteps: async (context, { boardId, stepsOrder }) => {
    try {
      await KanbanStepsAPI.reorderSteps(boardId, stepsOrder);
    } catch (error) {
      throw error;
    }
  },
};

const mutations = {
  SET_UI_FLAG: ($state, data) => {
    $state.uiFlags = { ...$state.uiFlags, ...data };
  },

  SET_STEPS: ($state, steps) => {
    steps.forEach(step => {
      $state.records = { ...$state.records, [step.id]: step };
    });
  },

  SET_STEP: ($state, step) => {
    $state.records = { ...$state.records, [step.id]: step };
  },

  DELETE_STEP: ($state, stepId) => {
    const { [stepId]: removed, ...remaining } = $state.records;
    $state.records = remaining;
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};

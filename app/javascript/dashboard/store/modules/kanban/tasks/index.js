import KanbanTasksAPI from '../../../../api/kanban/tasks';

const state = {
  records: {},
  meta: {},
  uiFlags: {
    isFetching: false,
    isCreating: false,
    isUpdating: false,
    isDeleting: false,
  },
};

const getters = {
  getUIFlags: $state => $state.uiFlags,
  getAllTasks: $state => Object.values($state.records),
  getTaskById: $state => id => $state.records[id],
  getTasksByStepId: $state => stepId => {
    return Object.values($state.records)
      .filter(task => task.step_id === stepId)
      .sort((a, b) => a.position - b.position);
  },
  getMeta: $state => $state.meta,
};

const actions = {
  get: async ({ commit }, taskId) => {
    commit('SET_UI_FLAG', { isFetching: true });
    try {
      const response = await KanbanTasksAPI.get(taskId);
      commit('SET_TASK', response.data);
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
      const response = await KanbanTasksAPI.index(params);
      const { tasks, meta } = response.data.payload;
      commit('SET_TASKS', tasks);
      commit('SET_META', meta);
      commit('SET_UI_FLAG', { isFetching: false });
      return tasks;
    } catch (error) {
      commit('SET_UI_FLAG', { isFetching: false });
      throw error;
    }
  },

  create: async ({ commit }, { taskData, insertBeforeTaskId }) => {
    commit('SET_UI_FLAG', { isCreating: true });
    try {
      const response = await KanbanTasksAPI.create(
        taskData,
        insertBeforeTaskId
      );
      commit('SET_TASK', response.data);
      commit('SET_UI_FLAG', { isCreating: false });
      return response.data;
    } catch (error) {
      commit('SET_UI_FLAG', { isCreating: false });
      throw error;
    }
  },

  update: async ({ commit }, { id, ...taskData }) => {
    commit('SET_UI_FLAG', { isUpdating: true });
    try {
      const response = await KanbanTasksAPI.update(id, taskData);
      commit('SET_TASK', response.data);
      commit('SET_UI_FLAG', { isUpdating: false });
      return response.data;
    } catch (error) {
      commit('SET_UI_FLAG', { isUpdating: false });
      throw error;
    }
  },

  delete: async ({ commit }, taskId) => {
    commit('SET_UI_FLAG', { isDeleting: true });
    try {
      await KanbanTasksAPI.delete(taskId);
      commit('DELETE_TASK', taskId);
      commit('SET_UI_FLAG', { isDeleting: false });
    } catch (error) {
      commit('SET_UI_FLAG', { isDeleting: false });
      throw error;
    }
  },

  moveTask: async ({ commit }, { taskId, stepId, insertBeforeTaskId }) => {
    commit('SET_UI_FLAG', { isUpdating: true });
    try {
      const response = await KanbanTasksAPI.moveTask(
        taskId,
        stepId,
        insertBeforeTaskId
      );
      commit('SET_TASK', response.data);
      commit('SET_UI_FLAG', { isUpdating: false });
      return response.data;
    } catch (error) {
      commit('SET_UI_FLAG', { isUpdating: false });
      throw error;
    }
  },

  getAuditEvents: async (context, { taskId, page }) => {
    const response = await KanbanTasksAPI.getAuditEvents(taskId, page);
    return response.data.payload;
  },
};

const mutations = {
  SET_UI_FLAG: ($state, data) => {
    $state.uiFlags = { ...$state.uiFlags, ...data };
  },

  SET_TASKS: ($state, tasks) => {
    tasks.forEach(task => {
      $state.records = { ...$state.records, [task.id]: task };
    });
  },

  SET_TASK: ($state, task) => {
    $state.records = { ...$state.records, [task.id]: task };
  },

  DELETE_TASK: ($state, taskId) => {
    const { [taskId]: removed, ...remaining } = $state.records;
    $state.records = remaining;
  },

  SET_META: ($state, meta) => {
    $state.meta = meta;
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};

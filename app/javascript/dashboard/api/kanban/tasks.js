/* global axios */
import ApiClient from '../ApiClient';

class KanbanTasksAPI extends ApiClient {
  constructor() {
    super('kanban/tasks', { accountScoped: true });
  }

  get(taskId) {
    return axios.get(`${this.url}/${taskId}`);
  }

  create(taskData, insertBeforeTaskId = null) {
    const payload = { task: taskData };
    if (insertBeforeTaskId) {
      payload.insert_before_task_id = insertBeforeTaskId;
    }
    return axios.post(this.url, payload);
  }

  update(taskId, taskData) {
    return axios.patch(`${this.url}/${taskId}`, {
      task: taskData,
    });
  }

  delete(taskId) {
    return axios.delete(`${this.url}/${taskId}`);
  }

  index(params = {}) {
    return axios.get(this.url, { params });
  }

  moveTask(taskId, stepId, insertBeforeTaskId = null) {
    const payload = { step_id: stepId };
    if (insertBeforeTaskId) {
      payload.insert_before_task_id = insertBeforeTaskId;
    }
    return axios.post(`${this.url}/${taskId}/move`, payload);
  }

  getAuditEvents(taskId, page = 1) {
    return axios.get(`${this.url}/${taskId}/audit_events`, {
      params: { page },
    });
  }
}

export default new KanbanTasksAPI();

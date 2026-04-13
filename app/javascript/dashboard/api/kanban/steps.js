/* global axios */
import ApiClient from '../ApiClient';

class KanbanStepsAPI extends ApiClient {
  constructor() {
    super('kanban/steps', { accountScoped: true });
  }

  get(stepId) {
    return axios.get(`${this.url}/${stepId}`);
  }

  create(boardId, stepData) {
    return axios.post(`${this.baseUrl()}/kanban/boards/${boardId}/steps`, {
      step: stepData,
    });
  }

  update(stepId, stepData) {
    return axios.patch(`${this.url}/${stepId}`, {
      step: stepData,
    });
  }

  delete(stepId) {
    return axios.delete(`${this.url}/${stepId}`);
  }

  index(params = {}) {
    return axios.get(this.url, { params });
  }

  reorderSteps(boardId, stepsOrder) {
    return axios.patch(
      `${this.baseUrl()}/kanban/boards/${boardId}/steps/reorder`,
      {
        steps_order: stepsOrder,
      }
    );
  }
}

export default new KanbanStepsAPI();

/* global axios */
import CacheEnabledApiClient from '../CacheEnabledApiClient';

export class KanbanBoardsAPI extends CacheEnabledApiClient {
  constructor() {
    super('kanban/boards', { accountScoped: true });
  }

  // eslint-disable-next-line class-methods-use-this
  get cacheModelName() {
    return 'kanbanBoard';
  }

  // eslint-disable-next-line class-methods-use-this
  extractDataFromResponse(response) {
    return response.data.payload || response.data;
  }

  // eslint-disable-next-line class-methods-use-this
  marshallData(dataToParse) {
    return { data: dataToParse };
  }

  toggleFavorite(boardId) {
    return axios.post(`${this.url}/${boardId}/toggle_favorite`);
  }

  updateAgents(boardId, agentIds) {
    return axios.post(`${this.url}/${boardId}/update_agents`, {
      agent_ids: agentIds,
    });
  }

  updateInboxes(boardId, inboxIds) {
    return axios.post(`${this.url}/${boardId}/update_inboxes`, {
      inbox_ids: inboxIds,
    });
  }

  getConversations(boardId, filters = {}) {
    return axios.get(`${this.url}/${boardId}/conversations`, {
      params: filters,
    });
  }
}

export default new KanbanBoardsAPI();

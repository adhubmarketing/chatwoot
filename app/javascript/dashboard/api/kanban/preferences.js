/* global axios */
import ApiClient from '../ApiClient';

class KanbanPreferencesAPI extends ApiClient {
  constructor() {
    super('kanban/preferences', { accountScoped: true });
  }

  update(preferences) {
    return axios.patch(this.url, { preferences });
  }
}

export default new KanbanPreferencesAPI();

import { frontendURL } from '../../../../helper/URLHelper';

const SettingsContent = () => import('../Wrapper.vue');
const KanbanSettings = () => import('./Index.vue');
const BoardSettings = () => import('./BoardSettings.vue');

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/kanban'),
      component: SettingsContent,
      props: {
        headerTitle: 'KANBAN.SETTINGS.TITLE',
        icon: 'view-column',
        showNewButton: false,
      },
      children: [
        {
          path: '',
          name: 'kanban_settings_index',
          meta: {
            permissions: ['administrator', 'agent'],
          },
          component: KanbanSettings,
        },
        {
          path: 'boards/:boardId',
          name: 'kanban_board_settings',
          meta: {
            permissions: ['administrator'],
          },
          component: BoardSettings,
        },
      ],
    },
  ],
};

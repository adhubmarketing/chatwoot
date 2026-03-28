<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';

const router = useRouter();
const store = useStore();
const { t } = useI18n();

const boards = computed(() => store.getters['kanbanBoards/getAllBoards']);
const uiFlags = computed(() => store.getters['kanbanBoards/getUIFlags']);

const showDeleteConfirm = ref(false);
const boardToDelete = ref(null);

onMounted(async () => {
  await store.dispatch('kanbanBoards/getAll');
});

const handleEdit = (boardId) => {
  router.push({
    name: 'kanban_board_settings',
    params: { boardId },
  });
};

const handleDelete = (board) => {
  boardToDelete.value = board;
  showDeleteConfirm.value = true;
};

const confirmDelete = async () => {
  if (!boardToDelete.value) return;

  try {
    await store.dispatch('kanbanBoards/delete', boardToDelete.value.id);
    useAlert(t('KANBAN.MESSAGES.BOARD_DELETED'));
    showDeleteConfirm.value = false;
    boardToDelete.value = null;
  } catch (error) {
    console.error('Failed to delete board:', error);
    useAlert(t('KANBAN.MESSAGES.ERROR'));
  }
};

const cancelDelete = () => {
  showDeleteConfirm.value = false;
  boardToDelete.value = null;
};
</script>

<template>
  <div class="flex flex-col h-full">
    <div class="p-6">
      <h2 class="mb-6 text-2xl font-semibold text-slate-900 dark:text-slate-25">
        {{ t('KANBAN.SETTINGS.TITLE') }}
      </h2>

      <!-- Loading State -->
      <div v-if="uiFlags.isFetching" class="flex items-center justify-center h-64">
        <spinner size="large" />
      </div>

      <!-- Empty State -->
      <div
        v-else-if="!boards.length"
        class="flex flex-col items-center justify-center h-64"
      >
        <fluent-icon
          icon="view-column"
          size="48"
          class="text-slate-400 dark:text-slate-500"
        />
        <p class="mt-4 text-slate-600 dark:text-slate-400">
          {{ t('KANBAN.NO_BOARDS') }}
        </p>
      </div>

      <!-- Boards Table -->
      <div v-else class="overflow-hidden border rounded-lg border-slate-200 dark:border-slate-700">
        <table class="min-w-full divide-y divide-slate-200 dark:divide-slate-700">
          <thead class="bg-slate-50 dark:bg-slate-800">
            <tr>
              <th class="px-6 py-3 text-xs font-medium tracking-wider text-left uppercase text-slate-700 dark:text-slate-300">
                {{ t('KANBAN.BOARD_NAME') }}
              </th>
              <th class="px-6 py-3 text-xs font-medium tracking-wider text-left uppercase text-slate-700 dark:text-slate-300">
                {{ t('KANBAN.BOARD_DESCRIPTION') }}
              </th>
              <th class="px-6 py-3 text-xs font-medium tracking-wider text-left uppercase text-slate-700 dark:text-slate-300">
                {{ t('KANBAN.STEPS.TITLE') }}
              </th>
              <th class="px-6 py-3 text-xs font-medium tracking-wider text-left uppercase text-slate-700 dark:text-slate-300">
                {{ t('KANBAN.TOTAL_TASKS') }}
              </th>
              <th class="px-6 py-3 text-xs font-medium tracking-wider text-right uppercase text-slate-700 dark:text-slate-300">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-slate-200 dark:bg-slate-900 dark:divide-slate-700">
            <tr
              v-for="board in boards"
              :key="board.id"
              class="hover:bg-slate-50 dark:hover:bg-slate-800"
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm font-medium text-slate-900 dark:text-slate-25">
                  {{ board.name }}
                </div>
              </td>
              <td class="px-6 py-4">
                <div class="text-sm text-slate-600 dark:text-slate-400 line-clamp-2">
                  {{ board.description || '-' }}
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-slate-600 dark:text-slate-400">
                  {{ board.steps_summary?.length || 0 }}
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-slate-600 dark:text-slate-400">
                  {{ board.total_tasks_count || 0 }}
                </div>
              </td>
              <td class="px-6 py-4 text-right whitespace-nowrap">
                <div class="flex justify-end gap-2">
                  <woot-button
                    variant="clear"
                    size="small"
                    icon="edit"
                    @click="handleEdit(board.id)"
                  >
                    {{ t('GENERAL_SETTINGS.EDIT') }}
                  </woot-button>
                  <woot-button
                    variant="clear"
                    size="small"
                    icon="delete"
                    color-scheme="alert"
                    @click="handleDelete(board)"
                  >
                    {{ t('GENERAL_SETTINGS.DELETE') }}
                  </woot-button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <woot-delete-modal
      v-if="showDeleteConfirm"
      :show.sync="showDeleteConfirm"
      :on-close="cancelDelete"
      :on-confirm="confirmDelete"
      :title="t('KANBAN.DELETE_BOARD')"
      :message="t('KANBAN.CONFIRM.DELETE_BOARD')"
      :confirm-text="t('GENERAL_SETTINGS.DELETE')"
      :reject-text="t('GENERAL_SETTINGS.CANCEL')"
    />
  </div>
</template>

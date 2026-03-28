<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import StepColumn from './components/StepColumn.vue';
import CreateTaskModal from './components/CreateTaskModal.vue';

const route = useRoute();
const router = useRouter();
const store = useStore();
const { t } = useI18n();

const boardId = computed(() => parseInt(route.params.boardId, 10));
const board = computed(() => store.getters['kanbanBoards/getBoardById'](boardId.value));
const steps = computed(() => {
  const allSteps = store.getters['kanbanSteps/getAllSteps'];
  return allSteps.filter(step => step.board_id === boardId.value);
});
const uiFlags = computed(() => store.getters['kanbanBoards/getUIFlags']);

const showCreateTaskModal = ref(false);
const selectedStepId = ref(null);
const selectedAgentId = ref(null);
const selectedInboxId = ref(null);

onMounted(async () => {
  await loadBoard();
});

watch(boardId, () => {
  loadBoard();
});

const loadBoard = async () => {
  try {
    await store.dispatch('kanbanBoards/get', boardId.value);
    await store.dispatch('kanbanSteps/getAll', { board_id: boardId.value });
    await store.dispatch('kanbanTasks/getAll', { board_id: boardId.value });
  } catch (error) {
    console.error('Failed to load board:', error);
  }
};

const handleCreateTask = (stepId) => {
  selectedStepId.value = stepId;
  showCreateTaskModal.value = true;
};

const handleTaskCreated = () => {
  showCreateTaskModal.value = false;
  selectedStepId.value = null;
  loadBoard();
};

const handleBack = () => {
  router.push({ name: 'kanban_overview' });
};

const toggleFavorite = async () => {
  await store.dispatch('kanbanBoards/toggleFavorite', boardId.value);
};

const goToSettings = () => {
  router.push({
    name: 'kanban_board_settings',
    params: { boardId: boardId.value },
  });
};

const preferences = computed(() => store.getters['kanbanBoards/getPreferences']);
const isFavorite = computed(() => {
  const favoriteIds = preferences.value?.favorite_board_ids || [];
  return favoriteIds.includes(boardId.value);
});
</script>

<template>
  <div class="flex flex-col h-full">
    <!-- Header -->
    <div class="flex items-center justify-between p-4 border-b border-slate-75 dark:border-slate-800">
      <div class="flex items-center gap-4">
        <woot-button
          variant="clear"
          color-scheme="secondary"
          icon="arrow-left"
          @click="handleBack"
        />
        <div>
          <div class="flex items-center gap-2">
            <h1 class="text-xl font-semibold text-slate-900 dark:text-slate-25">
              {{ board?.name || 'Board' }}
            </h1>
            <button
              class="text-slate-400 hover:text-yellow-500 dark:text-slate-500"
              @click="toggleFavorite"
            >
              <fluent-icon
                :icon="isFavorite ? 'star' : 'star-outline'"
                size="20"
                :class="{ 'text-yellow-500': isFavorite }"
              />
            </button>
          </div>
          <p v-if="board?.description" class="text-sm text-slate-600 dark:text-slate-400">
            {{ board.description }}
          </p>
        </div>
      </div>

      <div class="flex items-center gap-2">
        <!-- Filters placeholder -->
        <select
          v-model="selectedAgentId"
          class="px-3 py-2 text-sm border rounded-md border-slate-200 dark:border-slate-700"
        >
          <option :value="null">{{ t('KANBAN.FILTERS.ALL') }} Agents</option>
        </select>

        <select
          v-model="selectedInboxId"
          class="px-3 py-2 text-sm border rounded-md border-slate-200 dark:border-slate-700"
        >
          <option :value="null">{{ t('KANBAN.FILTERS.ALL') }} Inboxes</option>
        </select>

        <woot-button
          icon="settings"
          variant="clear"
          color-scheme="secondary"
          @click="goToSettings"
        />
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="uiFlags.isFetching" class="flex items-center justify-center flex-1">
      <spinner size="large" />
    </div>

    <!-- Board Columns -->
    <div v-else class="flex flex-1 gap-4 p-4 overflow-x-auto">
      <StepColumn
        v-for="step in steps"
        :key="step.id"
        :step="step"
        :board-id="boardId"
        @create-task="handleCreateTask"
      />

      <!-- Add Step Button -->
      <div class="flex-shrink-0 w-80">
        <button
          class="flex items-center justify-center w-full h-12 gap-2 text-sm font-medium transition-colors border-2 border-dashed rounded-lg border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-400 hover:border-woot-500 hover:text-woot-500"
        >
          <fluent-icon icon="add" size="20" />
          <span>{{ t('KANBAN.STEPS.ADD_STEP') }}</span>
        </button>
      </div>
    </div>

    <!-- Create Task Modal -->
    <CreateTaskModal
      v-if="showCreateTaskModal"
      :board-id="boardId"
      :step-id="selectedStepId"
      @close="showCreateTaskModal = false"
      @created="handleTaskCreated"
    />
  </div>
</template>

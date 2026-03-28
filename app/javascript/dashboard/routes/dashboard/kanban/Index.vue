<script setup>
import { ref, computed, onMounted } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import BoardCard from './components/BoardCard.vue';
import CreateBoardModal from './components/CreateBoardModal.vue';

const store = useStore();
const { t } = useI18n();

const showCreateModal = ref(false);

const boards = computed(() => store.getters['kanbanBoards/getAllBoards']);
const favoriteBoards = computed(() => store.getters['kanbanBoards/getFavoriteBoards']);
const uiFlags = computed(() => store.getters['kanbanBoards/getUIFlags']);

onMounted(async () => {
  await store.dispatch('kanbanBoards/getAll');
});

const handleCreateBoard = () => {
  showCreateModal.value = true;
};

const handleBoardCreated = () => {
  showCreateModal.value = false;
  store.dispatch('kanbanBoards/getAll');
};
</script>

<template>
  <div class="flex flex-col h-full overflow-auto">
    <!-- Header -->
    <div class="flex items-center justify-between p-6 border-b border-slate-75 dark:border-slate-800">
      <div>
        <h1 class="text-2xl font-semibold text-slate-900 dark:text-slate-25">
          {{ t('KANBAN.HEADER') }}
        </h1>
        <p class="mt-1 text-sm text-slate-600 dark:text-slate-400">
          {{ t('KANBAN.OVERVIEW') }}
        </p>
      </div>
      <woot-button
        icon="add"
        color-scheme="primary"
        @click="handleCreateBoard"
      >
        {{ t('KANBAN.CREATE_BOARD') }}
      </woot-button>
    </div>

    <!-- Loading State -->
    <div v-if="uiFlags.isFetching" class="flex items-center justify-center h-full">
      <spinner size="large" />
    </div>

    <!-- Empty State -->
    <div
      v-else-if="!boards.length"
      class="flex flex-col items-center justify-center h-full p-8"
    >
      <fluent-icon
        icon="view-column"
        size="48"
        class="text-slate-400 dark:text-slate-500"
      />
      <h3 class="mt-4 text-lg font-medium text-slate-900 dark:text-slate-25">
        {{ t('KANBAN.NO_BOARDS') }}
      </h3>
      <woot-button
        class="mt-4"
        icon="add"
        color-scheme="primary"
        @click="handleCreateBoard"
      >
        {{ t('KANBAN.ADD_BOARD') }}
      </woot-button>
    </div>

    <!-- Boards Grid -->
    <div v-else class="p-6">
      <!-- Favorite Boards -->
      <div v-if="favoriteBoards.length" class="mb-8">
        <h2 class="mb-4 text-lg font-medium text-slate-900 dark:text-slate-25">
          {{ t('KANBAN.FAVORITE') }}
        </h2>
        <div class="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          <BoardCard
            v-for="board in favoriteBoards"
            :key="board.id"
            :board="board"
          />
        </div>
      </div>

      <!-- All Boards -->
      <div>
        <h2 class="mb-4 text-lg font-medium text-slate-900 dark:text-slate-25">
          {{ t('KANBAN.BOARDS') }}
        </h2>
        <div class="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          <BoardCard
            v-for="board in boards"
            :key="board.id"
            :board="board"
          />
        </div>
      </div>
    </div>

    <!-- Create Board Modal -->
    <CreateBoardModal
      v-if="showCreateModal"
      @close="showCreateModal = false"
      @created="handleBoardCreated"
    />
  </div>
</template>

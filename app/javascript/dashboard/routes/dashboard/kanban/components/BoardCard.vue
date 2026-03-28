<script setup>
import { computed } from 'vue';
import { useRouter } from 'vue-router';
import { useStore } from 'vuex';
import { useI18n } from 'dashboard/composables/useI18n';

const props = defineProps({
  board: {
    type: Object,
    required: true,
  },
});

const router = useRouter();
const store = useStore();
const { t } = useI18n();

const preferences = computed(() => store.getters['kanbanBoards/getPreferences']);
const isFavorite = computed(() => {
  const favoriteIds = preferences.value?.favorite_board_ids || [];
  return favoriteIds.includes(props.board.id);
});

const totalTasks = computed(() => props.board.total_tasks_count || 0);

const stepsCount = computed(() => {
  return props.board.steps_summary?.length || 0;
});

const handleClick = () => {
  router.push({
    name: 'kanban_board_view',
    params: { boardId: props.board.id },
  });
};

const toggleFavorite = async (event) => {
  event.stopPropagation();
  await store.dispatch('kanbanBoards/toggleFavorite', props.board.id);
};
</script>

<template>
  <div
    class="relative p-6 transition-all border rounded-lg cursor-pointer border-slate-200 dark:border-slate-700 hover:shadow-md hover:border-woot-500 dark:hover:border-woot-600"
    @click="handleClick"
  >
    <!-- Favorite Icon -->
    <button
      class="absolute top-4 right-4 text-slate-400 hover:text-yellow-500 dark:text-slate-500 dark:hover:text-yellow-400"
      @click="toggleFavorite"
    >
      <fluent-icon
        :icon="isFavorite ? 'star' : 'star-outline'"
        size="20"
        :class="{ 'text-yellow-500': isFavorite }"
      />
    </button>

    <!-- Board Info -->
    <div class="pr-8">
      <h3 class="text-lg font-semibold text-slate-900 dark:text-slate-25">
        {{ board.name }}
      </h3>
      <p
        v-if="board.description"
        class="mt-2 text-sm text-slate-600 dark:text-slate-400 line-clamp-2"
      >
        {{ board.description }}
      </p>
    </div>

    <!-- Stats -->
    <div class="flex items-center gap-4 mt-4 text-sm text-slate-600 dark:text-slate-400">
      <div class="flex items-center gap-1">
        <fluent-icon icon="view-column" size="16" />
        <span>{{ stepsCount }} steps</span>
      </div>
      <div class="flex items-center gap-1">
        <fluent-icon icon="task-list-square-ltr" size="16" />
        <span>{{ totalTasks }} {{ t('KANBAN.TOTAL_TASKS') }}</span>
      </div>
    </div>

    <!-- Steps Preview -->
    <div v-if="board.steps_summary?.length" class="flex gap-2 mt-4">
      <div
        v-for="step in board.steps_summary.slice(0, 5)"
        :key="step.id"
        class="h-2 rounded-full flex-1"
        :style="{ backgroundColor: step.color }"
        :title="`${step.name}: ${step.tasks_count} tasks`"
      />
      <span
        v-if="board.steps_summary.length > 5"
        class="text-xs text-slate-500"
      >
        +{{ board.steps_summary.length - 5 }}
      </span>
    </div>
  </div>
</template>

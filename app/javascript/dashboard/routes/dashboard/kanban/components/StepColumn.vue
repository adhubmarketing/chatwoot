<script setup>
import { computed } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'dashboard/composables/useI18n';
import draggable from 'vuedraggable';
import TaskCard from './TaskCard.vue';

const props = defineProps({
  step: {
    type: Object,
    required: true,
  },
  boardId: {
    type: Number,
    required: true,
  },
});

const emit = defineEmits(['create-task']);

const store = useStore();
const { t } = useI18n();

const tasks = computed(() => {
  return store.getters['kanbanTasks/getTasksByStepId'](props.step.id);
});

const handleDragEnd = async (event) => {
  const { newIndex, oldIndex } = event;
  if (newIndex === oldIndex) return;

  const task = tasks.value[newIndex];
  const insertBeforeTask = tasks.value[newIndex + 1];

  try {
    await store.dispatch('kanbanTasks/moveTask', {
      taskId: task.id,
      stepId: props.step.id,
      insertBeforeTaskId: insertBeforeTask?.id,
    });
  } catch (error) {
    console.error('Failed to move task:', error);
    // Reload tasks to reset state
    await store.dispatch('kanbanTasks/getAll', { board_id: props.boardId });
  }
};

const handleCreateTask = () => {
  emit('create-task', props.step.id);
};
</script>

<template>
  <div class="flex flex-col flex-shrink-0 w-80">
    <!-- Step Header -->
    <div
      class="flex items-center justify-between p-4 mb-2 rounded-t-lg"
      :style="{ backgroundColor: step.color + '20', borderTop: `3px solid ${step.color}` }"
    >
      <div class="flex items-center gap-2">
        <h3 class="font-semibold text-slate-900 dark:text-slate-25">
          {{ step.name }}
        </h3>
        <span
          class="px-2 py-1 text-xs font-medium rounded-full bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400"
        >
          {{ step.tasks_count }}
        </span>
      </div>

      <button class="text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200">
        <fluent-icon icon="more-vertical" size="16" />
      </button>
    </div>

    <!-- Tasks List -->
    <draggable
      :list="tasks"
      item-key="id"
      class="flex-1 min-h-0 p-2 space-y-2 overflow-y-auto bg-slate-50 dark:bg-slate-900 rounded-b-lg"
      group="tasks"
      @end="handleDragEnd"
    >
      <template #item="{ element }">
        <TaskCard :task="element" />
      </template>
    </draggable>

    <!-- Add Task Button -->
    <button
      class="flex items-center justify-center w-full gap-2 p-3 mt-2 text-sm font-medium transition-colors border border-dashed rounded-lg border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-400 hover:border-woot-500 hover:text-woot-500 hover:bg-slate-50 dark:hover:bg-slate-800"
      @click="handleCreateTask"
    >
      <fluent-icon icon="add" size="16" />
      <span>{{ t('KANBAN.TASKS.ADD_TASK') }}</span>
    </button>
  </div>
</template>

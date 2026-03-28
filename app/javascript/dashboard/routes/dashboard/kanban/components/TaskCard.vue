<script setup>
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';

const props = defineProps({
  task: {
    type: Object,
    required: true,
  },
});

const { t } = useI18n();

const priorityColors = {
  urgent: 'bg-red-100 text-red-700 dark:bg-red-900 dark:text-red-300',
  high: 'bg-orange-100 text-orange-700 dark:bg-orange-900 dark:text-orange-300',
  medium: 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900 dark:text-yellow-300',
  low: 'bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300',
};

const priorityClass = computed(() => {
  return priorityColors[props.task.priority] || priorityColors.medium;
});

const isOverdue = computed(() => {
  if (!props.task.due_date) return false;
  return new Date(props.task.due_date) < new Date();
});

const labels = computed(() => {
  if (!props.task.label_list) return [];
  return Array.isArray(props.task.label_list)
    ? props.task.label_list
    : props.task.label_list.split(',').map(l => l.trim());
});
</script>

<template>
  <div
    class="p-4 transition-all bg-white border rounded-lg cursor-pointer border-slate-200 dark:bg-slate-800 dark:border-slate-700 hover:shadow-md"
  >
    <!-- Priority Badge -->
    <div class="flex items-start justify-between mb-2">
      <span
        class="px-2 py-1 text-xs font-medium rounded"
        :class="priorityClass"
      >
        {{ t(`KANBAN.PRIORITY.${task.priority.toUpperCase()}`) }}
      </span>
      <button class="text-slate-400 hover:text-slate-600 dark:hover:text-slate-200">
        <fluent-icon icon="more-horizontal" size="16" />
      </button>
    </div>

    <!-- Task Title -->
    <h4 class="mb-2 text-sm font-medium text-slate-900 dark:text-slate-25">
      {{ task.title }}
    </h4>

    <!-- Task Description (truncated) -->
    <p
      v-if="task.description"
      class="mb-3 text-xs text-slate-600 dark:text-slate-400 line-clamp-2"
    >
      {{ task.description }}
    </p>

    <!-- Labels -->
    <div v-if="labels.length" class="flex flex-wrap gap-1 mb-3">
      <span
        v-for="label in labels.slice(0, 3)"
        :key="label"
        class="px-2 py-1 text-xs rounded bg-slate-100 dark:bg-slate-700 text-slate-700 dark:text-slate-300"
      >
        {{ label }}
      </span>
      <span
        v-if="labels.length > 3"
        class="px-2 py-1 text-xs rounded bg-slate-100 dark:bg-slate-700 text-slate-500"
      >
        +{{ labels.length - 3 }}
      </span>
    </div>

    <!-- Footer -->
    <div class="flex items-center justify-between pt-3 border-t border-slate-100 dark:border-slate-700">
      <!-- Assigned Agents -->
      <div class="flex -space-x-2">
        <div
          v-for="agent in task.assigned_agents?.slice(0, 3)"
          :key="agent.id"
          class="w-6 h-6 overflow-hidden border-2 border-white rounded-full dark:border-slate-800"
        >
          <thumbnail
            v-if="agent.thumbnail"
            :src="agent.thumbnail"
            :username="agent.name"
            size="24px"
          />
          <div
            v-else
            class="flex items-center justify-center w-full h-full text-xs font-medium text-white bg-woot-500"
          >
            {{ agent.name?.charAt(0).toUpperCase() }}
          </div>
        </div>
        <span
          v-if="task.assigned_agents?.length > 3"
          class="flex items-center justify-center w-6 h-6 text-xs font-medium border-2 border-white rounded-full bg-slate-200 dark:bg-slate-700 dark:border-slate-800 text-slate-600 dark:text-slate-400"
        >
          +{{ task.assigned_agents.length - 3 }}
        </span>
      </div>

      <!-- Due Date -->
      <div
        v-if="task.due_date"
        class="flex items-center gap-1 text-xs"
        :class="isOverdue ? 'text-red-600 dark:text-red-400' : 'text-slate-500 dark:text-slate-400'"
      >
        <fluent-icon icon="calendar" size="12" />
        <span>{{ new Date(task.due_date).toLocaleDateString() }}</span>
      </div>
    </div>
  </div>
</template>

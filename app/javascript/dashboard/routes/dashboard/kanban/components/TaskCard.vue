<script setup>
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import Icon from 'dashboard/components-next/icon/Icon.vue';

const props = defineProps({
  task: {
    type: Object,
    required: true,
  },
});

const emit = defineEmits(['click']);

const { t } = useI18n();

const priorityConfig = {
  urgent: {
    badge: 'bg-n-ruby-3 text-n-ruby-11 border border-n-ruby-6',
    dot: 'bg-n-ruby-9',
    label: 'KANBAN.PRIORITY.URGENT',
  },
  high: {
    badge: 'bg-n-amber-3 text-n-amber-11 border border-n-amber-6',
    dot: 'bg-n-amber-9',
    label: 'KANBAN.PRIORITY.HIGH',
  },
  medium: {
    badge: 'bg-n-blue-3 text-n-blue-11 border border-n-blue-6',
    dot: 'bg-n-blue-9',
    label: 'KANBAN.PRIORITY.MEDIUM',
  },
  low: {
    badge: 'bg-n-teal-3 text-n-teal-11 border border-n-teal-6',
    dot: 'bg-n-teal-9',
    label: 'KANBAN.PRIORITY.LOW',
  },
};

const priorityDotClass = computed(() => {
  return priorityConfig[props.task.priority]?.dot || '';
});

const priorityLabel = computed(() => {
  const key = priorityConfig[props.task.priority]?.label;
  return key ? t(key) : '';
});

const isOverdue = computed(() => {
  if (!props.task.due_date) return false;
  return new Date(props.task.due_date) < new Date();
});

const labels = computed(() => {
  if (!props.task.label_list) return [];
  return Array.isArray(props.task.label_list)
    ? props.task.label_list
    : props.task.label_list
        .split(',')
        .map(l => l.trim())
        .filter(Boolean);
});

const formatDate = dateString => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' });
};

const getAgentInitials = name => {
  if (!name) return '?';
  return name.charAt(0).toUpperCase();
};

const avatarColors = [
  'bg-n-violet-9',
  'bg-n-blue-9',
  'bg-n-teal-9',
  'bg-n-amber-9',
  'bg-n-ruby-9',
  'bg-n-pink-9',
  'bg-n-iris-9',
];

const getAvatarColor = index => {
  return avatarColors[index % avatarColors.length];
};

const handleClick = () => {
  emit('click', props.task);
};
</script>

<template>
  <div
    class="p-3 transition-all bg-n-surface-0 border rounded-lg cursor-pointer border-n-weak hover:shadow-md hover:border-n-slate-4 group relative"
    @click="handleClick"
  >
    <!-- Priority Indicator (small dot) -->
    <div
      v-if="task.priority && task.priority !== 'medium'"
      class="absolute top-2 right-2 w-2 h-2 rounded-full"
      :class="priorityDotClass"
      :title="priorityLabel"
    />

    <!-- Task Title -->
    <h4 class="mb-2 text-sm font-medium text-n-slate-12 line-clamp-2 pr-4">
      {{ task.title }}
    </h4>

    <!-- Labels -->
    <div v-if="labels.length" class="flex flex-wrap gap-1 mb-2">
      <span
        v-for="label in labels.slice(0, 2)"
        :key="label"
        class="px-2 py-0.5 text-xs rounded bg-n-blue-3 text-n-blue-11 border border-n-blue-6"
      >
        {{ label }}
      </span>
      <span
        v-if="labels.length > 2"
        class="px-2 py-0.5 text-xs rounded bg-n-slate-3 text-n-slate-11"
      >
        +{{ labels.length - 2 }}
      </span>
    </div>

    <!-- Footer -->
    <div
      class="flex items-center justify-between pt-2 mt-2 border-t border-n-weak"
    >
      <!-- Assigned Agents -->
      <div v-if="task.assigned_agents?.length" class="flex -space-x-2">
        <div
          v-for="(agent, index) in task.assigned_agents.slice(0, 3)"
          :key="agent.id"
          class="w-6 h-6 flex items-center justify-center text-xs font-medium text-white border-2 border-n-surface-0 rounded-full"
          :class="getAvatarColor(index)"
          :title="agent.name"
        >
          {{ getAgentInitials(agent.name) }}
        </div>
        <span
          v-if="task.assigned_agents.length > 3"
          class="flex items-center justify-center w-6 h-6 text-xs font-medium border-2 border-n-surface-0 rounded-full bg-n-slate-3 text-n-slate-11"
          :title="`+${task.assigned_agents.length - 3} mais`"
        >
          +{{ task.assigned_agents.length - 3 }}
        </span>
      </div>
      <div v-else class="w-6 h-6" />

      <!-- Due Date -->
      <div
        v-if="task.due_date"
        class="flex items-center gap-1 text-xs"
        :class="isOverdue ? 'text-n-ruby-11 font-medium' : 'text-n-slate-11'"
      >
        <Icon icon="i-lucide-calendar" class="size-3.5" />
        <span>{{ formatDate(task.due_date) }}</span>
      </div>
    </div>

    <!-- Hover Edit Icon -->
    <div
      class="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity"
      :class="{ 'right-5': task.priority && task.priority !== 'medium' }"
    >
      <Icon
        icon="i-lucide-pencil"
        class="size-4 text-n-slate-9 hover:text-n-slate-12"
      />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';

const props = defineProps({
  board: {
    type: Object,
    required: true,
  },
});

const router = useRouter();
const { t } = useI18n();

const totalTasks = computed(() => props.board.total_tasks_count || 0);

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

const getAgentInitials = name => {
  if (!name) return '?';
  return name.charAt(0).toUpperCase();
};

const handleClick = () => {
  router.push({
    name: 'kanban_board_view',
    params: { boardId: props.board.id },
  });
};
</script>

<template>
  <div
    class="flex flex-col gap-4 p-5 rounded-xl bg-n-surface-0 outline outline-1 -outline-offset-1 outline-n-weak hover:outline-n-slate-6 hover:shadow-md cursor-pointer transition-all"
    @click="handleClick"
  >
    <!-- Header with Board Name, Count and Avatars -->
    <div class="flex items-start justify-between">
      <div class="flex items-center gap-3">
        <h3 class="text-lg font-semibold text-n-slate-12">
          {{ board.name }}
        </h3>
        <span
          class="px-2.5 py-1 text-xs font-semibold rounded-md bg-n-slate-3 text-n-slate-11"
        >
          {{ totalTasks }}
        </span>
      </div>

      <!-- Agent Avatars -->
      <div v-if="board.assigned_agents?.length" class="flex -space-x-2">
        <div
          v-for="(agent, index) in board.assigned_agents.slice(0, 3)"
          :key="agent.id"
          class="w-9 h-9 rounded-full border-2 border-n-surface-0 flex items-center justify-center text-xs text-white font-semibold shadow-sm"
          :class="getAvatarColor(index)"
          :style="{ zIndex: board.assigned_agents.length - index }"
          :title="agent.name"
        >
          {{ getAgentInitials(agent.name) }}
        </div>
        <div
          v-if="board.assigned_agents.length > 3"
          class="w-9 h-9 rounded-full bg-n-slate-3 border-2 border-n-surface-0 flex items-center justify-center text-xs font-semibold text-n-slate-11 shadow-sm"
          :title="`+${board.assigned_agents.length - 3} mais`"
        >
          +{{ board.assigned_agents.length - 3 }}
        </div>
      </div>
    </div>

    <!-- Steps Badges -->
    <div v-if="board.steps_summary?.length" class="flex flex-wrap gap-3">
      <div
        v-for="step in board.steps_summary"
        :key="step.id"
        class="flex items-center gap-2 px-2 py-1 rounded-md bg-n-alpha-1 outline outline-1 -outline-offset-1 outline-n-weak text-sm"
      >
        <span
          class="w-3 h-3 rounded-full flex-shrink-0"
          :style="{ backgroundColor: step.color }"
        />
        <span class="text-n-slate-12 font-medium">
          {{ step.name }}
        </span>
        <span class="text-n-slate-11 font-medium">
          {{ step.tasks_count || 0 }}
        </span>
      </div>
    </div>

    <!-- Empty State for Steps -->
    <div v-else class="text-sm text-n-slate-9 italic">
      {{ t('KANBAN.STEPS.NO_STEPS') }}
    </div>
  </div>
</template>

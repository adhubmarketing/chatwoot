<script setup>
import { ref, computed, onMounted, watch, reactive } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import draggable from 'vuedraggable';
import Button from 'dashboard/components-next/button/Button.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';
import Spinner from 'dashboard/components-next/spinner/Spinner.vue';
import TaskCard from './components/TaskCard.vue';
import EditStepModal from './components/EditStepModal.vue';
import CreateStepModal from './components/CreateStepModal.vue';
import TaskModal from './components/TaskModal.vue';

const route = useRoute();
const router = useRouter();
const store = useStore();
const { t } = useI18n();

const boardId = computed(() => parseInt(route.params.boardId, 10));
const board = computed(
  () => store.getters['kanbanBoards/getBoardById'](boardId.value) || null
);
const steps = computed(() => {
  const allSteps = store.getters['kanbanSteps/getAllSteps'] || [];
  return allSteps.filter(step => step.board_id === boardId.value);
});
const uiFlags = computed(() => store.getters['kanbanBoards/getUIFlags'] || {});

// Modal states
const createStepModalRef = ref(null);
const editStepModalRef = ref(null);
const taskModalRef = ref(null);

const editingStepId = ref(null);
const editingTaskId = ref(null);
const selectedStepIdForTask = ref(null);

// Filters
const selectedAgentId = ref('all');
const selectedInboxId = ref('all');

// Collapsed columns
const collapsedSteps = reactive(new Set());

const agents = computed(() => board.value?.assigned_agents || []);
const inboxes = computed(() => board.value?.assigned_inboxes || []);

const loadBoard = async () => {
  try {
    await store.dispatch('kanbanBoards/get', boardId.value);
    await store.dispatch('kanbanSteps/getAll', { board_id: boardId.value });
    await store.dispatch('kanbanTasks/getAll', { board_id: boardId.value });
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to load board:', error);
    useAlert(error?.response?.message || t('KANBAN.MESSAGES.ERROR_LOAD_BOARD'));
  }
};

onMounted(async () => {
  await loadBoard();
});

watch(boardId, () => {
  loadBoard();
});

const handleBack = () => {
  router.push({ name: 'kanban_overview' });
};

// Step actions
const handleAddStep = () => {
  createStepModalRef.value?.open();
};

const handleEditStep = stepId => {
  editingStepId.value = stepId;
  editStepModalRef.value?.open();
};

const handleStepCreated = async () => {
  await loadBoard();
};

const handleStepUpdated = async () => {
  await loadBoard();
  editingStepId.value = null;
};

// Task actions
const handleCreateTask = (stepId = null) => {
  editingTaskId.value = null;
  selectedStepIdForTask.value = stepId;
  taskModalRef.value?.open();
};

const handleEditTask = task => {
  editingTaskId.value = task.id;
  selectedStepIdForTask.value = task.step_id;
  taskModalRef.value?.open();
};

const handleTaskSaved = async () => {
  await loadBoard();
  editingTaskId.value = null;
  selectedStepIdForTask.value = null;
};

const handleTaskDeleted = async () => {
  await loadBoard();
  editingTaskId.value = null;
  selectedStepIdForTask.value = null;
};

// Column collapse
const toggleColumnCollapse = stepId => {
  if (collapsedSteps.has(stepId)) {
    collapsedSteps.delete(stepId);
  } else {
    collapsedSteps.add(stepId);
  }
};

const isColumnCollapsed = stepId => {
  return collapsedSteps.has(stepId);
};

const goToSettings = () => {
  router.push({
    name: 'kanban_board_settings',
    params: { boardId: boardId.value },
  });
};

const getTasksByStep = stepId => {
  const allTasks = store.getters['kanbanTasks/getAllTasks'] || [];
  return allTasks.filter(task => task.step_id === stepId);
};

const handleTaskMoved = async (event, stepId) => {
  const { added } = event;

  if (added) {
    const task = added.element;
    const tasksInStep = getTasksByStep(stepId);
    const insertBeforeTaskId =
      added.newIndex < tasksInStep.length - 1
        ? tasksInStep[added.newIndex + 1]?.id
        : null;

    try {
      await store.dispatch('kanbanTasks/moveTask', {
        taskId: task.id,
        stepId: stepId,
        insertBeforeTaskId,
      });
      await loadBoard();
      useAlert(t('KANBAN.MESSAGES.TASK_MOVED'));
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error('Failed to move task:', error);
      useAlert(
        error?.response?.message || t('KANBAN.MESSAGES.ERROR_MOVE_TASK')
      );
      await loadBoard();
    }
  }
};
</script>

<template>
  <!-- eslint-disable vue/no-static-inline-styles -->
  <div class="flex flex-col h-full bg-n-background">
    <!-- Header -->
    <div
      class="flex items-center justify-between px-6 py-4 border-b border-n-weak"
    >
      <div class="flex items-center gap-4">
        <Button
          icon="i-lucide-arrow-left"
          variant="ghost"
          color="slate"
          @click="handleBack"
        />
        <div class="flex items-center gap-3">
          <h1 class="text-xl font-semibold text-n-slate-12">
            {{ board?.name || t('KANBAN.BOARDS') }}
          </h1>
          <span
            class="px-2 py-0.5 text-xs font-medium rounded bg-n-slate-3 text-n-slate-11"
          >
            {{ board?.total_tasks_count || 0 }}
          </span>
        </div>
      </div>

      <div class="flex items-center gap-3">
        <!-- Agent Filter -->
        <select
          v-model="selectedAgentId"
          class="px-4 py-2 text-sm rounded-lg bg-n-alpha-black2 text-n-slate-12 outline outline-1 outline-n-weak focus:outline-n-brand"
        >
          <option value="all">{{ t('KANBAN.FILTERS.ALL') }}</option>
          <option v-for="agent in agents" :key="agent.id" :value="agent.id">
            {{ agent.name }}
          </option>
        </select>

        <!-- Inbox Filter -->
        <select
          v-model="selectedInboxId"
          class="px-4 py-2 text-sm rounded-lg bg-n-alpha-black2 text-n-slate-12 outline outline-1 outline-n-weak focus:outline-n-brand"
        >
          <option value="all">{{ t('KANBAN.FILTERS.ALL') }}</option>
          <option v-for="inbox in inboxes" :key="inbox.id" :value="inbox.id">
            {{ inbox.name }}
          </option>
        </select>

        <!-- Settings Button -->
        <Button
          icon="i-lucide-settings"
          variant="ghost"
          color="slate"
          @click="goToSettings"
        />

        <!-- Add Task Button -->
        <Button
          icon="i-lucide-plus"
          :label="t('KANBAN.TASKS.ADD_TASK')"
          color="blue"
          @click="handleCreateTask()"
        />
      </div>
    </div>

    <!-- Loading State -->
    <div
      v-if="uiFlags.isFetching"
      class="flex items-center justify-center flex-1"
    >
      <Spinner :size="32" />
    </div>

    <!-- Board Columns -->
    <div v-else class="flex flex-1 gap-4 p-6 overflow-x-auto">
      <!-- Step Columns -->
      <template v-for="step in steps" :key="step.id">
        <!-- Collapsed Column -->
        <div
          v-if="isColumnCollapsed(step.id)"
          class="flex flex-col items-center py-3 px-2 rounded-xl cursor-pointer h-full min-h-[400px]"
          :style="{ backgroundColor: step.color || '#6B7280' }"
          @click="toggleColumnCollapse(step.id)"
        >
          <Icon icon="i-lucide-chevron-right" class="text-white mb-2 size-4" />
          <span class="text-white text-sm font-medium mb-2">
            {{ getTasksByStep(step.id).length }}
          </span>
          <span
            class="text-white text-xs font-medium whitespace-nowrap"
            style="writing-mode: vertical-rl; text-orientation: mixed"
          >
            {{ step.name }}
          </span>
        </div>

        <!-- Expanded Column -->
        <div
          v-else
          class="flex h-full flex-shrink-0 flex-col overflow-hidden rounded-xl bg-n-surface-0 w-80"
        >
          <!-- Column Header -->
          <div
            class="flex items-center justify-between px-4 py-3"
            :style="{
              backgroundColor: step.color || '#6B7280',
            }"
          >
            <div class="flex items-center gap-2">
              <button
                class="p-1 hover:bg-white/20 rounded text-white"
                @click.stop="toggleColumnCollapse(step.id)"
              >
                <Icon icon="i-lucide-chevron-left" class="size-4" />
              </button>
              <span class="font-medium text-white">{{ step.name }}</span>
              <span
                class="px-2 py-0.5 rounded-full bg-white/20 text-xs text-white"
              >
                {{ getTasksByStep(step.id).length }}
              </span>
            </div>
            <div class="flex items-center gap-1">
              <button
                class="p-1 hover:bg-white/20 rounded text-white"
                @click.stop="handleEditStep(step.id)"
              >
                <Icon icon="i-lucide-settings" class="size-4" />
              </button>
              <button
                class="p-1 hover:bg-white/20 rounded text-white"
                @click.stop="handleCreateTask(step.id)"
              >
                <Icon icon="i-lucide-plus" class="size-4" />
              </button>
            </div>
          </div>

          <!-- Tasks List -->
          <div
            class="flex-1 p-3 overflow-y-auto"
            :style="{
              backgroundColor: `color-mix(in srgb, ${step.color || '#6B7280'}, transparent 92%)`,
            }"
          >
            <!-- Add Task Link -->
            <Button
              icon="i-lucide-plus"
              :label="t('KANBAN.TASKS.ADD_TASK')"
              variant="ghost"
              color="slate"
              size="sm"
              class="w-full mb-2 justify-start"
              @click="handleCreateTask(step.id)"
            />

            <!-- Task Cards - Draggable -->
            <draggable
              :list="getTasksByStep(step.id)"
              :group="{ name: 'tasks' }"
              item-key="id"
              class="min-h-[400px] space-y-2"
              @change="e => handleTaskMoved(e, step.id)"
            >
              <template #item="{ element }">
                <TaskCard :task="element" @click="handleEditTask" />
                <!-- eslint-enable vue/no-static-inline-styles -->
              </template>
            </draggable>
          </div>
        </div>
        <!-- eslint-enable vue/no-static-inline-styles -->
      </template>

      <!-- Add Step Button -->
      <div class="flex-shrink-0 w-80 flex items-start pt-3">
        <Button
          icon="i-lucide-plus"
          :label="t('KANBAN.STEPS.ADD_STEP')"
          variant="outline"
          color="blue"
          class="w-full border-2 border-dashed"
          @click="handleAddStep"
        />
      </div>
    </div>

    <!-- Create Step Modal -->
    <CreateStepModal
      ref="createStepModalRef"
      :board-id="boardId"
      @created="handleStepCreated"
    />

    <!-- Edit Step Modal -->
    <EditStepModal
      v-if="editingStepId"
      ref="editStepModalRef"
      :step-id="editingStepId"
      :board-id="boardId"
      @close="editingStepId = null"
      @updated="handleStepUpdated"
      @deleted="handleStepUpdated"
    />

    <!-- Task Modal (Create/Edit) -->
    <TaskModal
      ref="taskModalRef"
      :board-id="boardId"
      :task-id="editingTaskId"
      :initial-step-id="selectedStepIdForTask"
      @saved="handleTaskSaved"
      @deleted="handleTaskDeleted"
    />
  </div>
  <!-- eslint-enable vue/no-static-inline-styles -->
</template>

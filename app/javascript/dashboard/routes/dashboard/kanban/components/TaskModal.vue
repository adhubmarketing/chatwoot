<script setup>
import { ref, computed } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';
import DeleteConfirmDialog from './DeleteConfirmDialog.vue';

const props = defineProps({
  boardId: {
    type: Number,
    required: true,
  },
  taskId: {
    type: Number,
    default: null,
  },
  initialStepId: {
    type: Number,
    default: null,
  },
});

const emit = defineEmits(['close', 'saved', 'deleted']);

const store = useStore();
const { t } = useI18n();

const dialogRef = ref(null);
const deleteDialogRef = ref(null);

// Form state
const title = ref('');
const description = ref('');
const selectedStepId = ref(null);
const selectedAgentIds = ref([]);
const labels = ref('');
const startDate = ref('');
const dueDate = ref('');
const priority = ref('');

const isSubmitting = ref(false);
const isDeleting = ref(false);
const isLoading = ref(false);

const characterLimit = 5000;
const characterCount = computed(() => description.value.length);

const isEditing = computed(() => !!props.taskId);
const modalTitle = computed(() =>
  isEditing.value ? t('KANBAN.TASKS.EDIT_TASK') : t('KANBAN.TASKS.ADD_TASK')
);

const board = computed(() =>
  store.getters['kanbanBoards/getBoardById'](props.boardId)
);
const steps = computed(() => {
  const allSteps = store.getters['kanbanSteps/getAllSteps'] || [];
  return allSteps.filter(step => step.board_id === props.boardId);
});
const agents = computed(() => board.value?.assigned_agents || []);

const selectedStep = computed(() => {
  if (!selectedStepId.value) return null;
  return steps.value.find(s => s.id === selectedStepId.value);
});

const canSubmit = computed(() => {
  return title.value.trim().length > 0 && !isSubmitting.value;
});

const priorityOptions = [
  { value: '', label: 'Nenhuma' },
  { value: 'low', label: 'Baixa' },
  { value: 'medium', label: 'Média' },
  { value: 'high', label: 'Alta' },
  { value: 'urgent', label: 'Urgente' },
];

const resetForm = () => {
  title.value = '';
  description.value = '';
  selectedStepId.value = props.initialStepId;
  selectedAgentIds.value = [];
  labels.value = '';
  startDate.value = '';
  dueDate.value = '';
  priority.value = '';
};

const loadTask = async () => {
  if (!props.taskId) return;

  isLoading.value = true;
  try {
    const task = await store.dispatch('kanbanTasks/get', props.taskId);
    title.value = task.title || '';
    description.value = task.description || '';
    selectedStepId.value = task.step_id;
    selectedAgentIds.value = task.assigned_agents?.map(a => a.id) || [];
    labels.value = Array.isArray(task.label_list)
      ? task.label_list.join(', ')
      : task.label_list || '';
    startDate.value = task.start_date ? task.start_date.split('T')[0] : '';
    dueDate.value = task.due_date ? task.due_date.split('T')[0] : '';
    priority.value = task.priority || '';
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to load task:', error);
    useAlert(t('KANBAN.MESSAGES.ERROR'));
  } finally {
    isLoading.value = false;
  }
};

const open = () => {
  if (isEditing.value) {
    loadTask();
  } else {
    resetForm();
  }
  dialogRef.value?.open();
};

const close = () => {
  dialogRef.value?.close();
  emit('close');
};

const toggleAgent = agentId => {
  const index = selectedAgentIds.value.indexOf(agentId);
  if (index > -1) {
    selectedAgentIds.value.splice(index, 1);
  } else {
    selectedAgentIds.value.push(agentId);
  }
};

const removeAgent = agentId => {
  const index = selectedAgentIds.value.indexOf(agentId);
  if (index > -1) {
    selectedAgentIds.value.splice(index, 1);
  }
};

const handleSubmit = async () => {
  if (!canSubmit.value) return;

  isSubmitting.value = true;

  try {
    const taskData = {
      board_id: props.boardId,
      step_id: selectedStepId.value,
      title: title.value.trim(),
      description: description.value.trim(),
      start_date: startDate.value || null,
      due_date: dueDate.value || null,
      priority: priority.value || null,
      label_list: labels.value
        .split(',')
        .map(l => l.trim())
        .filter(Boolean),
    };

    if (isEditing.value) {
      await store.dispatch('kanbanTasks/update', {
        id: props.taskId,
        ...taskData,
        agent_ids: selectedAgentIds.value,
      });
      useAlert(t('KANBAN.MESSAGES.TASK_UPDATED'));
    } else {
      await store.dispatch('kanbanTasks/create', {
        taskData,
        agent_ids: selectedAgentIds.value,
      });
      useAlert(t('KANBAN.MESSAGES.TASK_CREATED'));
    }

    emit('saved');
    close();
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to save task:', error);
    useAlert(
      error?.response?.message ||
        t(
          isEditing.value
            ? 'KANBAN.MESSAGES.ERROR_UPDATE_TASK'
            : 'KANBAN.MESSAGES.ERROR_CREATE_TASK'
        )
    );
  } finally {
    isSubmitting.value = false;
  }
};

const handleDeleteClick = () => {
  deleteDialogRef.value?.open();
};

const handleDeleteConfirm = async () => {
  isDeleting.value = true;

  try {
    await store.dispatch('kanbanTasks/delete', props.taskId);
    useAlert(t('KANBAN.MESSAGES.TASK_DELETED'));
    deleteDialogRef.value?.close();
    emit('deleted');
    close();
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to delete task:', error);
    useAlert(
      error?.response?.message || t('KANBAN.MESSAGES.ERROR_DELETE_TASK')
    );
  } finally {
    isDeleting.value = false;
  }
};

defineExpose({ open, close });
</script>

<template>
  <!-- eslint-disable vue/no-bare-strings-in-template -->
  <Dialog
    ref="dialogRef"
    type="edit"
    :title="modalTitle"
    :show-confirm-button="false"
    :show-cancel-button="false"
    width="2xl"
    overflow-y-auto
    @close="close"
  >
    <!-- Header with ID -->
    <template #description>
      <div
        v-if="isEditing && taskId"
        class="flex items-center gap-2 text-sm text-n-slate-11"
      >
        <span>ID: {{ taskId }}</span>
      </div>
      <!-- eslint-enable vue/no-bare-strings-in-template -->
    </template>

    <!-- Loading State -->
    <div v-if="isLoading" class="flex items-center justify-center py-12">
      <div class="text-n-slate-11">Carregando...</div>
    </div>

    <!-- Form Content -->
    <div v-else class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Left Column -->
      <div class="space-y-4">
        <!-- Title -->
        <div>
          <label class="block text-sm font-medium text-n-slate-12 mb-2">
            {{ t('KANBAN.TASKS.TASK_TITLE') }}
          </label>
          <input
            v-model="title"
            type="text"
            :placeholder="t('KANBAN.TASKS.TASK_TITLE')"
            class="w-full px-3 py-2 rounded-lg bg-n-alpha-black2 text-n-slate-12 placeholder-n-slate-9 outline outline-1 outline-n-weak focus:outline-n-brand"
          />
        </div>

        <!-- Description -->
        <div>
          <label class="block text-sm font-medium text-n-slate-12 mb-2">
            {{ t('KANBAN.TASKS.TASK_DESCRIPTION') }}
          </label>
          <div class="relative">
            <textarea
              v-model="description"
              rows="10"
              :maxlength="characterLimit"
              :placeholder="t('KANBAN.TASKS.TASK_DESCRIPTION')"
              class="w-full px-3 py-2 pb-8 rounded-lg bg-n-alpha-black2 text-n-slate-12 placeholder-n-slate-9 outline outline-1 outline-n-weak focus:outline-n-brand resize-none"
            />
            <div class="absolute bottom-2 right-2 text-xs text-n-slate-9">
              {{ characterCount }} / {{ characterLimit }}
            </div>
          </div>
        </div>
      </div>

      <!-- Right Column -->
      <div class="space-y-4">
        <!-- Agents -->
        <div>
          <label class="block text-sm font-medium text-n-slate-12 mb-2">
            {{ t('KANBAN.TASKS.ASSIGN_AGENTS') }}
          </label>
          <div class="flex flex-wrap gap-2 mb-2">
            <span
              v-for="agentId in selectedAgentIds"
              :key="agentId"
              class="inline-flex items-center gap-1 px-3 py-1 text-sm bg-n-blue-3 text-n-blue-11 border border-n-blue-6 rounded-full"
            >
              {{ agents.find(a => a.id === agentId)?.name || 'Agent' }}
              <button
                type="button"
                class="hover:text-n-blue-12"
                @click="removeAgent(agentId)"
              >
                <Icon icon="i-lucide-x" class="size-3" />
              </button>
            </span>
          </div>
          <select
            class="w-full px-3 py-2 text-sm rounded-lg bg-n-alpha-black2 text-n-slate-12 outline outline-1 outline-n-weak focus:outline-n-brand"
            @change="
              e => {
                toggleAgent(parseInt(e.target.value));
                e.target.value = '';
              }
            "
          >
            <option value="">{{ t('KANBAN.TASKS.ASSIGN_AGENTS') }}</option>
            <option
              v-for="agent in agents"
              :key="agent.id"
              :value="agent.id"
              :disabled="selectedAgentIds.includes(agent.id)"
            >
              {{ agent.name }}
            </option>
          </select>
        </div>

        <!-- Labels -->
        <div>
          <label class="block text-sm font-medium text-n-slate-12 mb-2">
            {{ t('KANBAN.TASKS.LABELS') }}
          </label>
          <input
            v-model="labels"
            type="text"
            :placeholder="t('KANBAN.TASKS.LABELS')"
            class="w-full px-3 py-2 rounded-lg bg-n-alpha-black2 text-n-slate-12 placeholder-n-slate-9 outline outline-1 outline-n-weak focus:outline-n-brand"
          />
          <p class="mt-1 text-xs text-n-slate-9">
            Separe as etiquetas com vírgulas
          </p>
        </div>

        <!-- Conversations (placeholder) -->
        <div>
          <label class="block text-sm font-medium text-n-slate-12 mb-2">
            {{ t('KANBAN.CONVERSATIONS.TITLE') }}
          </label>
          <input
            type="text"
            :placeholder="t('KANBAN.CONVERSATIONS.SEARCH_CONVERSATIONS')"
            disabled
            class="w-full px-3 py-2 rounded-lg bg-n-slate-2 text-n-slate-9 placeholder-n-slate-9 cursor-not-allowed outline outline-1 outline-n-weak"
          />
        </div>

        <!-- Contacts (placeholder) -->
        <div>
          <label class="block text-sm font-medium text-n-slate-12 mb-2">
            {{ t('KANBAN.CONTACTS.TITLE') }}
          </label>
          <input
            type="text"
            :placeholder="t('KANBAN.CONTACTS.SEARCH_CONTACTS')"
            disabled
            class="w-full px-3 py-2 rounded-lg bg-n-slate-2 text-n-slate-9 placeholder-n-slate-9 cursor-not-allowed outline outline-1 outline-n-weak"
          />
        </div>

        <!-- Dates -->
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-n-slate-12 mb-2">
              {{ t('KANBAN.TASKS.START_DATE') }}
            </label>
            <input
              v-model="startDate"
              type="date"
              class="w-full px-3 py-2 rounded-lg bg-n-alpha-black2 text-n-slate-12 outline outline-1 outline-n-weak focus:outline-n-brand"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-n-slate-12 mb-2">
              {{ t('KANBAN.TASKS.DUE_DATE') }}
            </label>
            <input
              v-model="dueDate"
              type="date"
              class="w-full px-3 py-2 rounded-lg bg-n-alpha-black2 text-n-slate-12 outline outline-1 outline-n-weak focus:outline-n-brand"
            />
          </div>
        </div>
      </div>
    </div>

    <!-- Footer -->
    <template #footer>
      <div class="flex flex-wrap items-center justify-between w-full gap-3">
        <!-- Left side: Delete button (only in edit mode) -->
        <div class="flex-shrink-0">
          <Button
            v-if="isEditing"
            icon="i-lucide-trash-2"
            label="Excluir"
            variant="faded"
            color="ruby"
            @click="handleDeleteClick"
          />
        </div>

        <!-- Right side: Step, Priority, Cancel, Save -->
        <div class="flex flex-wrap items-center gap-2">
          <!-- Step Selector -->
          <div class="flex items-center gap-2">
            <div
              v-if="selectedStep"
              class="w-3 h-3 rounded-full flex-shrink-0"
              :style="{ backgroundColor: selectedStep.color }"
            />
            <select
              v-model="selectedStepId"
              class="px-3 py-2 text-sm rounded-lg bg-n-alpha-black2 text-n-slate-12 outline outline-1 outline-n-weak focus:outline-n-brand"
            >
              <option :value="null">Selecionar etapa</option>
              <option v-for="step in steps" :key="step.id" :value="step.id">
                {{ step.name }}
              </option>
            </select>
          </div>

          <!-- Priority Selector -->
          <select
            v-model="priority"
            class="px-3 py-2 text-sm rounded-lg bg-n-alpha-black2 text-n-slate-12 outline outline-1 outline-n-weak focus:outline-n-brand"
          >
            <option
              v-for="opt in priorityOptions"
              :key="opt.value"
              :value="opt.value"
            >
              {{ opt.label }}
            </option>
          </select>

          <Button
            label="Cancelar"
            variant="faded"
            color="slate"
            @click="close"
          />
          <Button
            :label="
              isSubmitting ? 'Salvando...' : isEditing ? 'Atualizar' : 'Criar'
            "
            color="blue"
            :disabled="!canSubmit"
            :is-loading="isSubmitting"
            @click="handleSubmit"
          />
        </div>
      </div>
      <!-- eslint-enable vue/no-bare-strings-in-template -->
    </template>
  </Dialog>

  <!-- Delete Confirmation Dialog -->
  <DeleteConfirmDialog
    ref="deleteDialogRef"
    :title="t('KANBAN.CONFIRM.DELETE_TASK')"
    :description="t('KANBAN.CONFIRM.DELETE_TASK_DESCRIPTION')"
    :is-loading="isDeleting"
    @confirm="handleDeleteConfirm"
  />
  <!-- eslint-enable vue/no-bare-strings-in-template -->
</template>

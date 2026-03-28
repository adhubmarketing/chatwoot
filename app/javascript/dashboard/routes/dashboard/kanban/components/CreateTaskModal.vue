<script setup>
import { ref, computed } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'dashboard/composables/useI18n';
import { useAlert } from 'dashboard/composables';

const props = defineProps({
  boardId: {
    type: Number,
    required: true,
  },
  stepId: {
    type: Number,
    default: null,
  },
});

const emit = defineEmits(['close', 'created']);

const store = useStore();
const { t } = useI18n();

const title = ref('');
const description = ref('');
const priority = ref('medium');
const startDate = ref('');
const dueDate = ref('');
const selectedStepId = ref(props.stepId);
const selectedAgentIds = ref([]);
const selectedLabels = ref([]);
const isSubmitting = ref(false);

const characterCount = computed(() => description.value.length);
const characterLimit = 5000;

const steps = computed(() => {
  const allSteps = store.getters['kanbanSteps/getAllSteps'];
  return allSteps.filter(step => step.board_id === props.boardId);
});

const priorities = [
  { value: 'low', label: t('KANBAN.PRIORITY.LOW'), color: 'green' },
  { value: 'medium', label: t('KANBAN.PRIORITY.MEDIUM'), color: 'yellow' },
  { value: 'high', label: t('KANBAN.PRIORITY.HIGH'), color: 'orange' },
  { value: 'urgent', label: t('KANBAN.PRIORITY.URGENT'), color: 'red' },
];

const handleSubmit = async () => {
  if (!title.value.trim()) {
    useAlert(t('KANBAN.TASKS.TASK_TITLE') + ' is required');
    return;
  }

  if (description.value.length > characterLimit) {
    useAlert(t('KANBAN.MESSAGES.ERROR'));
    return;
  }

  isSubmitting.value = true;

  try {
    const taskData = {
      board_id: props.boardId,
      step_id: selectedStepId.value,
      title: title.value.trim(),
      description: description.value.trim(),
      priority: priority.value,
      start_date: startDate.value || null,
      due_date: dueDate.value || null,
      label_list: selectedLabels.value,
    };

    const payload = {
      taskData,
      agent_ids: selectedAgentIds.value,
    };

    await store.dispatch('kanbanTasks/create', payload);
    useAlert(t('KANBAN.MESSAGES.TASK_CREATED'));
    emit('created');
  } catch (error) {
    console.error('Failed to create task:', error);
    useAlert(t('KANBAN.MESSAGES.ERROR'));
  } finally {
    isSubmitting.value = false;
  }
};

const handleClose = () => {
  emit('close');
};
</script>

<template>
  <woot-modal :show.sync="true" :on-close="handleClose">
    <div class="flex flex-col w-full max-w-3xl max-h-[90vh] p-6">
      <h3 class="mb-6 text-xl font-semibold text-slate-900 dark:text-slate-25">
        {{ t('KANBAN.TASKS.ADD_TASK') }}
      </h3>

      <form class="flex-1 overflow-y-auto" @submit.prevent="handleSubmit">
        <!-- Task Title -->
        <div class="mb-4">
          <label class="block mb-2 text-sm font-medium text-slate-700 dark:text-slate-300">
            {{ t('KANBAN.TASKS.TASK_TITLE') }} *
          </label>
          <input
            v-model="title"
            type="text"
            class="w-full px-3 py-2 border rounded-lg border-slate-300 dark:border-slate-600 focus:outline-none focus:ring-2 focus:ring-woot-500"
            :placeholder="t('KANBAN.TASKS.TASK_TITLE')"
            required
          />
        </div>

        <!-- Step Selection -->
        <div class="mb-4">
          <label class="block mb-2 text-sm font-medium text-slate-700 dark:text-slate-300">
            Step
          </label>
          <select
            v-model="selectedStepId"
            class="w-full px-3 py-2 border rounded-lg border-slate-300 dark:border-slate-600 focus:outline-none focus:ring-2 focus:ring-woot-500"
          >
            <option :value="null">{{ t('KANBAN.STEPS.NO_STEPS') }}</option>
            <option
              v-for="step in steps"
              :key="step.id"
              :value="step.id"
            >
              {{ step.name }}
            </option>
          </select>
        </div>

        <!-- Priority -->
        <div class="mb-4">
          <label class="block mb-2 text-sm font-medium text-slate-700 dark:text-slate-300">
            {{ t('KANBAN.TASKS.PRIORITY') }}
          </label>
          <div class="flex gap-2">
            <button
              v-for="p in priorities"
              :key="p.value"
              type="button"
              class="flex-1 px-4 py-2 text-sm font-medium transition-all border-2 rounded-lg"
              :class="
                priority === p.value
                  ? `border-${p.color}-500 bg-${p.color}-50 text-${p.color}-700`
                  : 'border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-400 hover:border-slate-300'
              "
              @click="priority = p.value"
            >
              {{ p.label }}
            </button>
          </div>
        </div>

        <!-- Description -->
        <div class="mb-4">
          <label class="block mb-2 text-sm font-medium text-slate-700 dark:text-slate-300">
            {{ t('KANBAN.TASKS.TASK_DESCRIPTION') }}
          </label>
          <textarea
            v-model="description"
            rows="4"
            class="w-full px-3 py-2 border rounded-lg border-slate-300 dark:border-slate-600 focus:outline-none focus:ring-2 focus:ring-woot-500"
            :placeholder="t('KANBAN.TASKS.TASK_DESCRIPTION')"
            :maxlength="characterLimit"
          />
          <div class="mt-1 text-xs text-right text-slate-500">
            {{ t('KANBAN.TASKS.CHARACTER_COUNT', { count: characterCount }) }}
          </div>
        </div>

        <!-- Dates -->
        <div class="grid grid-cols-2 gap-4 mb-4">
          <div>
            <label class="block mb-2 text-sm font-medium text-slate-700 dark:text-slate-300">
              {{ t('KANBAN.TASKS.START_DATE') }}
            </label>
            <input
              v-model="startDate"
              type="date"
              class="w-full px-3 py-2 border rounded-lg border-slate-300 dark:border-slate-600 focus:outline-none focus:ring-2 focus:ring-woot-500"
            />
          </div>
          <div>
            <label class="block mb-2 text-sm font-medium text-slate-700 dark:text-slate-300">
              {{ t('KANBAN.TASKS.DUE_DATE') }}
            </label>
            <input
              v-model="dueDate"
              type="date"
              class="w-full px-3 py-2 border rounded-lg border-slate-300 dark:border-slate-600 focus:outline-none focus:ring-2 focus:ring-woot-500"
            />
          </div>
        </div>

        <!-- Labels -->
        <div class="mb-6">
          <label class="block mb-2 text-sm font-medium text-slate-700 dark:text-slate-300">
            {{ t('KANBAN.TASKS.LABELS') }}
          </label>
          <input
            v-model="selectedLabels"
            type="text"
            class="w-full px-3 py-2 border rounded-lg border-slate-300 dark:border-slate-600 focus:outline-none focus:ring-2 focus:ring-woot-500"
            placeholder="Enter labels separated by commas"
          />
        </div>

        <!-- Actions -->
        <div class="flex justify-end gap-2 pt-4 border-t border-slate-200 dark:border-slate-700">
          <woot-button variant="clear" @click="handleClose">
            {{ t('GENERAL_SETTINGS.CANCEL') }}
          </woot-button>
          <woot-button
            type="submit"
            color-scheme="primary"
            :is-loading="isSubmitting"
            :disabled="!title.trim()"
          >
            {{ t('KANBAN.TASKS.ADD_TASK') }}
          </woot-button>
        </div>
      </form>
    </div>
  </woot-modal>
</template>

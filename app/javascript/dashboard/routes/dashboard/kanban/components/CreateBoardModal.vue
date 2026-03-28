<script setup>
import { ref } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';

const emit = defineEmits(['close', 'created']);

const store = useStore();
const { t } = useI18n();

const name = ref('');
const description = ref('');
const selectedTemplate = ref('empty');
const isSubmitting = ref(false);

const templates = [
  {
    id: 'empty',
    name: t('KANBAN.TEMPLATES.EMPTY'),
    description: t('KANBAN.TEMPLATES.EMPTY_DESCRIPTION'),
    icon: 'view-column',
  },
  {
    id: 'sales',
    name: t('KANBAN.TEMPLATES.SALES'),
    description: t('KANBAN.TEMPLATES.SALES_DESCRIPTION'),
    icon: 'currency-dollar',
  },
  {
    id: 'support',
    name: t('KANBAN.TEMPLATES.SUPPORT'),
    description: t('KANBAN.TEMPLATES.SUPPORT_DESCRIPTION'),
    icon: 'headset',
  },
  {
    id: 'recruitment',
    name: t('KANBAN.TEMPLATES.RECRUITMENT'),
    description: t('KANBAN.TEMPLATES.RECRUITMENT_DESCRIPTION'),
    icon: 'people',
  },
];

const handleSubmit = async () => {
  if (!name.value.trim()) {
    useAlert(t('KANBAN.BOARD_NAME') + ' is required');
    return;
  }

  isSubmitting.value = true;

  try {
    const boardData = {
      name: name.value.trim(),
      description: description.value.trim(),
      settings: {},
    };

    const board = await store.dispatch('kanbanBoards/create', boardData);

    // Create steps based on template
    if (selectedTemplate.value !== 'empty') {
      await createTemplateSteps(board.id);
    }

    useAlert(t('KANBAN.MESSAGES.BOARD_CREATED'));
    emit('created', board);
  } catch (error) {
    console.error('Failed to create board:', error);
    useAlert(t('KANBAN.MESSAGES.ERROR'));
  } finally {
    isSubmitting.value = false;
  }
};

const createTemplateSteps = async (boardId) => {
  const stepTemplates = {
    sales: [
      { name: 'Lead', color: '#6B7280' },
      { name: 'Qualified', color: '#3B82F6' },
      { name: 'Proposal', color: '#F59E0B' },
      { name: 'Negotiation', color: '#8B5CF6' },
      { name: 'Won', color: '#10B981' },
      { name: 'Lost', color: '#EF4444', cancelled: true },
    ],
    support: [
      { name: 'New', color: '#6B7280' },
      { name: 'In Progress', color: '#3B82F6' },
      { name: 'Waiting', color: '#F59E0B' },
      { name: 'Resolved', color: '#10B981' },
    ],
    recruitment: [
      { name: 'Applied', color: '#6B7280' },
      { name: 'Screening', color: '#3B82F6' },
      { name: 'Interview', color: '#8B5CF6' },
      { name: 'Offer', color: '#F59E0B' },
      { name: 'Hired', color: '#10B981' },
      { name: 'Rejected', color: '#EF4444', cancelled: true },
    ],
  };

  const steps = stepTemplates[selectedTemplate.value] || [];

  for (const step of steps) {
    await store.dispatch('kanbanSteps/create', {
      boardId,
      stepData: step,
    });
  }
};

const handleClose = () => {
  emit('close');
};
</script>

<template>
  <woot-modal :show.sync="true" :on-close="handleClose">
    <div class="flex flex-col w-full max-w-2xl p-6">
      <h3 class="mb-6 text-xl font-semibold text-slate-900 dark:text-slate-25">
        {{ t('KANBAN.CREATE_BOARD') }}
      </h3>

      <form @submit.prevent="handleSubmit">
        <!-- Board Name -->
        <div class="mb-4">
          <label class="block mb-2 text-sm font-medium text-slate-700 dark:text-slate-300">
            {{ t('KANBAN.BOARD_NAME') }}
          </label>
          <input
            v-model="name"
            type="text"
            class="w-full px-3 py-2 border rounded-lg border-slate-300 dark:border-slate-600 focus:outline-none focus:ring-2 focus:ring-woot-500"
            :placeholder="t('KANBAN.BOARD_NAME')"
            required
          />
        </div>

        <!-- Board Description -->
        <div class="mb-6">
          <label class="block mb-2 text-sm font-medium text-slate-700 dark:text-slate-300">
            {{ t('KANBAN.BOARD_DESCRIPTION') }}
          </label>
          <textarea
            v-model="description"
            rows="3"
            class="w-full px-3 py-2 border rounded-lg border-slate-300 dark:border-slate-600 focus:outline-none focus:ring-2 focus:ring-woot-500"
            :placeholder="t('KANBAN.BOARD_DESCRIPTION')"
          />
        </div>

        <!-- Template Selection -->
        <div class="mb-6">
          <label class="block mb-3 text-sm font-medium text-slate-700 dark:text-slate-300">
            {{ t('KANBAN.TEMPLATES.TITLE') }}
          </label>
          <div class="grid grid-cols-2 gap-3">
            <div
              v-for="template in templates"
              :key="template.id"
              class="p-4 transition-all border-2 rounded-lg cursor-pointer"
              :class="
                selectedTemplate === template.id
                  ? 'border-woot-500 bg-woot-50 dark:bg-woot-900'
                  : 'border-slate-200 dark:border-slate-700 hover:border-slate-300'
              "
              @click="selectedTemplate = template.id"
            >
              <fluent-icon :icon="template.icon" size="24" class="mb-2 text-woot-500" />
              <h4 class="mb-1 text-sm font-semibold text-slate-900 dark:text-slate-25">
                {{ template.name }}
              </h4>
              <p class="text-xs text-slate-600 dark:text-slate-400">
                {{ template.description }}
              </p>
            </div>
          </div>
        </div>

        <!-- Actions -->
        <div class="flex justify-end gap-2">
          <woot-button variant="clear" @click="handleClose">
            {{ t('GENERAL_SETTINGS.CANCEL') }}
          </woot-button>
          <woot-button
            type="submit"
            color-scheme="primary"
            :is-loading="isSubmitting"
            :disabled="!name.trim()"
          >
            {{ t('KANBAN.CREATE_BOARD') }}
          </woot-button>
        </div>
      </form>
    </div>
  </woot-modal>
</template>

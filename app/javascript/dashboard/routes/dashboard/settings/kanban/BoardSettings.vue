<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useStore } from 'vuex';
import { useI18n } from 'dashboard/composables/useI18n';
import { useAlert } from 'dashboard/composables';
import StepEditor from './components/StepEditor.vue';

const route = useRoute();
const router = useRouter();
const store = useStore();
const { t } = useI18n();

const boardId = computed(() => parseInt(route.params.boardId, 10));
const board = computed(() => store.getters['kanbanBoards/getBoardById'](boardId.value));
const steps = computed(() => {
  const allSteps = store.getters['kanbanSteps/getAllSteps'];
  return allSteps.filter(step => step.board_id === boardId.value);
});

const activeTab = ref('basic');
const name = ref('');
const description = ref('');
const settings = ref({});
const isSubmitting = ref(false);

const showStepEditor = ref(false);
const editingStep = ref(null);

const tabs = [
  { id: 'basic', label: t('KANBAN.SETTINGS.BASIC_INFO'), icon: 'info' },
  { id: 'steps', label: t('KANBAN.SETTINGS.STEPS_TAB'), icon: 'view-column' },
  { id: 'agents', label: t('KANBAN.SETTINGS.AGENTS_TAB'), icon: 'people' },
  { id: 'inboxes', label: t('KANBAN.SETTINGS.INBOXES_TAB'), icon: 'mail-inbox' },
  { id: 'automation', label: t('KANBAN.SETTINGS.AUTOMATION_TAB'), icon: 'bot' },
];

onMounted(async () => {
  await loadBoard();
});

const loadBoard = async () => {
  await store.dispatch('kanbanBoards/get', boardId.value);
  await store.dispatch('kanbanSteps/getAll', { board_id: boardId.value });

  if (board.value) {
    name.value = board.value.name;
    description.value = board.value.description || '';
    settings.value = board.value.settings || {};
  }
};

const handleSaveBasicInfo = async () => {
  isSubmitting.value = true;
  try {
    await store.dispatch('kanbanBoards/update', {
      id: boardId.value,
      name: name.value,
      description: description.value,
    });
    useAlert(t('KANBAN.MESSAGES.BOARD_UPDATED'));
  } catch (error) {
    console.error('Failed to update board:', error);
    useAlert(t('KANBAN.MESSAGES.ERROR'));
  } finally {
    isSubmitting.value = false;
  }
};

const handleEditStep = (step) => {
  editingStep.value = step;
  showStepEditor.value = true;
};

const handleAddStep = () => {
  editingStep.value = null;
  showStepEditor.value = true;
};

const handleStepSaved = () => {
  showStepEditor.value = false;
  editingStep.value = null;
  loadBoard();
};

const handleBack = () => {
  router.push({ name: 'kanban_settings_index' });
};
</script>

<template>
  <div class="flex flex-col h-full">
    <!-- Header -->
    <div class="flex items-center gap-4 p-6 border-b border-slate-75 dark:border-slate-800">
      <woot-button
        variant="clear"
        color-scheme="secondary"
        icon="arrow-left"
        @click="handleBack"
      />
      <div>
        <h2 class="text-2xl font-semibold text-slate-900 dark:text-slate-25">
          {{ board?.name || 'Board Settings' }}
        </h2>
        <p class="text-sm text-slate-600 dark:text-slate-400">
          {{ t('KANBAN.BOARD_SETTINGS') }}
        </p>
      </div>
    </div>

    <!-- Tabs -->
    <div class="flex gap-1 px-6 pt-6 border-b border-slate-200 dark:border-slate-700">
      <button
        v-for="tab in tabs"
        :key="tab.id"
        class="flex items-center gap-2 px-4 py-2 text-sm font-medium transition-colors border-b-2"
        :class="
          activeTab === tab.id
            ? 'border-woot-500 text-woot-600 dark:text-woot-400'
            : 'border-transparent text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-200'
        "
        @click="activeTab = tab.id"
      >
        <fluent-icon :icon="tab.icon" size="16" />
        <span>{{ tab.label }}</span>
      </button>
    </div>

    <!-- Tab Content -->
    <div class="flex-1 p-6 overflow-y-auto">
      <!-- Basic Info Tab -->
      <div v-if="activeTab === 'basic'" class="max-w-2xl">
        <form @submit.prevent="handleSaveBasicInfo">
          <div class="mb-4">
            <label class="block mb-2 text-sm font-medium text-slate-700 dark:text-slate-300">
              {{ t('KANBAN.BOARD_NAME') }}
            </label>
            <input
              v-model="name"
              type="text"
              class="w-full px-3 py-2 border rounded-lg border-slate-300 dark:border-slate-600"
              required
            />
          </div>

          <div class="mb-6">
            <label class="block mb-2 text-sm font-medium text-slate-700 dark:text-slate-300">
              {{ t('KANBAN.BOARD_DESCRIPTION') }}
            </label>
            <textarea
              v-model="description"
              rows="4"
              class="w-full px-3 py-2 border rounded-lg border-slate-300 dark:border-slate-600"
            />
          </div>

          <woot-button
            type="submit"
            color-scheme="primary"
            :is-loading="isSubmitting"
          >
            {{ t('GENERAL_SETTINGS.SAVE') }}
          </woot-button>
        </form>
      </div>

      <!-- Steps Tab -->
      <div v-if="activeTab === 'steps'">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-medium text-slate-900 dark:text-slate-25">
            {{ t('KANBAN.STEPS.TITLE') }}
          </h3>
          <woot-button
            icon="add"
            color-scheme="primary"
            @click="handleAddStep"
          >
            {{ t('KANBAN.STEPS.ADD_STEP') }}
          </woot-button>
        </div>

        <div v-if="!steps.length" class="py-12 text-center text-slate-500">
          {{ t('KANBAN.STEPS.NO_STEPS') }}
        </div>

        <div v-else class="space-y-2">
          <div
            v-for="step in steps"
            :key="step.id"
            class="flex items-center justify-between p-4 border rounded-lg border-slate-200 dark:border-slate-700"
          >
            <div class="flex items-center gap-3">
              <div
                class="w-4 h-4 rounded"
                :style="{ backgroundColor: step.color }"
              />
              <div>
                <h4 class="font-medium text-slate-900 dark:text-slate-25">
                  {{ step.name }}
                </h4>
                <p v-if="step.description" class="text-sm text-slate-600 dark:text-slate-400">
                  {{ step.description }}
                </p>
              </div>
              <span
                v-if="step.cancelled"
                class="px-2 py-1 text-xs rounded bg-red-100 dark:bg-red-900 text-red-700 dark:text-red-300"
              >
                {{ t('KANBAN.STEPS.CANCELLED') }}
              </span>
            </div>
            <div class="flex items-center gap-2">
              <span class="text-sm text-slate-600 dark:text-slate-400">
                {{ step.tasks_count }} tasks
              </span>
              <woot-button
                variant="clear"
                size="small"
                icon="edit"
                @click="handleEditStep(step)"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Other tabs placeholder -->
      <div v-if="activeTab === 'agents'" class="text-slate-600 dark:text-slate-400">
        {{ t('KANBAN.SETTINGS.ASSIGNED_AGENTS') }} - Coming soon
      </div>

      <div v-if="activeTab === 'inboxes'" class="text-slate-600 dark:text-slate-400">
        {{ t('KANBAN.SETTINGS.ASSIGNED_INBOXES') }} - Coming soon
      </div>

      <div v-if="activeTab === 'automation'" class="text-slate-600 dark:text-slate-400">
        {{ t('KANBAN.SETTINGS.AUTOMATION_TAB') }} - Coming soon
      </div>
    </div>

    <!-- Step Editor Modal -->
    <StepEditor
      v-if="showStepEditor"
      :board-id="boardId"
      :step="editingStep"
      @close="showStepEditor = false"
      @saved="handleStepSaved"
    />
  </div>
</template>

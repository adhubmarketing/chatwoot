<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import Button from 'dashboard/components-next/button/Button.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';
import Spinner from 'dashboard/components-next/spinner/Spinner.vue';
import DeleteConfirmDialog from './components/DeleteConfirmDialog.vue';
import EditStepModal from './components/EditStepModal.vue';
import CreateStepModal from './components/CreateStepModal.vue';

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

// Form state
const boardName = ref('');
const boardDescription = ref('');

// Modal refs
const deleteDialogRef = ref(null);
const editStepModalRef = ref(null);
const createStepModalRef = ref(null);
const deleteStepDialogRef = ref(null);

const editingStepId = ref(null);
const deletingStepId = ref(null);

// Loading states
const isLoading = ref(true);
const isSaving = ref(false);
const isDeleting = ref(false);
const isDeletingStep = ref(false);
const isUpdatingAgents = ref(false);
const isUpdatingInboxes = ref(false);

// Agents and Inboxes
const selectedAgentIds = ref([]);
const selectedInboxIds = ref([]);
const allAgents = computed(() => store.getters['agents/getAgents'] || []);
const allInboxes = computed(() => store.getters['inboxes/getInboxes'] || []);

// Automation settings
const autoCreateTask = ref(false);
const syncAgents = ref(false);
const autoAssign = ref(false);
const autoResolveConversation = ref(false);
const autoCompleteTask = ref(false);

const maxDescriptionLength = 2000;
const descriptionLength = computed(() => boardDescription.value.length);

const loadData = async () => {
  isLoading.value = true;
  try {
    await Promise.all([
      store.dispatch('kanbanBoards/get', boardId.value),
      store.dispatch('kanbanSteps/getAll', { board_id: boardId.value }),
      store.dispatch('agents/get'),
      store.dispatch('inboxes/get'),
    ]);

    // Populate form
    if (board.value) {
      boardName.value = board.value.name || '';
      boardDescription.value = board.value.description || '';
      selectedAgentIds.value =
        board.value.assigned_agents?.map(a => a.id) || [];
      selectedInboxIds.value =
        board.value.assigned_inboxes?.map(i => i.id) || [];

      // Load automation settings from board.settings
      const settings = board.value.settings || {};
      autoCreateTask.value = settings.auto_create_task || false;
      syncAgents.value = settings.sync_agents || false;
      autoAssign.value = settings.auto_assign || false;
      autoResolveConversation.value =
        settings.auto_resolve_conversation || false;
      autoCompleteTask.value = settings.auto_complete_task || false;
    }
  } catch (error) {
    // eslint-disable-next-line no-console
    // eslint-disable-next-line no-console
    console.error('Failed to load board:', error);
    useAlert(t('KANBAN.MESSAGES.ERROR_LOAD_BOARD'));
  } finally {
    isLoading.value = false;
  }
};

onMounted(async () => {
  await loadData();
});

watch(boardId, () => {
  loadData();
});

const handleBack = () => {
  router.push({
    name: 'kanban_board_view',
    params: { boardId: boardId.value },
  });
};

const handleSaveBasicInfo = async () => {
  if (!boardName.value.trim()) return;

  isSaving.value = true;
  try {
    await store.dispatch('kanbanBoards/update', {
      id: boardId.value,
      name: boardName.value.trim(),
      description: boardDescription.value.trim(),
    });
    useAlert(t('KANBAN.MESSAGES.BOARD_UPDATED'));
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to update board:', error);
    useAlert(
      error?.response?.message || t('KANBAN.MESSAGES.ERROR_UPDATE_BOARD')
    );
  } finally {
    isSaving.value = false;
  }
};

const handleSaveAutomation = async () => {
  isSaving.value = true;
  try {
    await store.dispatch('kanbanBoards/update', {
      id: boardId.value,
      settings: {
        auto_create_task: autoCreateTask.value,
        sync_agents: syncAgents.value,
        auto_assign: autoAssign.value,
        auto_resolve_conversation: autoResolveConversation.value,
        auto_complete_task: autoCompleteTask.value,
      },
    });
    useAlert(t('KANBAN.MESSAGES.BOARD_UPDATED'));
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to update automation:', error);
    useAlert(
      error?.response?.message || t('KANBAN.MESSAGES.ERROR_UPDATE_BOARD')
    );
  } finally {
    isSaving.value = false;
  }
};

// Step actions
const handleAddStep = () => {
  createStepModalRef.value?.open();
};

const handleEditStep = stepId => {
  editingStepId.value = stepId;
  editStepModalRef.value?.open();
};

const handleDeleteStepClick = stepId => {
  deletingStepId.value = stepId;
  deleteStepDialogRef.value?.open();
};

const handleDeleteStepConfirm = async () => {
  isDeletingStep.value = true;
  try {
    await store.dispatch('kanbanSteps/delete', deletingStepId.value);
    useAlert(t('KANBAN.MESSAGES.STEP_DELETED'));
    deleteStepDialogRef.value?.close();
    await loadData();
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to delete step:', error);
    useAlert(
      error?.response?.message || t('KANBAN.MESSAGES.ERROR_DELETE_STEP')
    );
  } finally {
    isDeletingStep.value = false;
    deletingStepId.value = null;
  }
};

const handleStepUpdated = async () => {
  await loadData();
  editingStepId.value = null;
};

// Agent actions
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

const handleUpdateAgents = async () => {
  isUpdatingAgents.value = true;
  try {
    await store.dispatch('kanbanBoards/updateAgents', {
      boardId: boardId.value,
      agentIds: selectedAgentIds.value,
    });
    useAlert(t('KANBAN.MESSAGES.AGENTS_UPDATED'));
    await loadData();
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to update agents:', error);
    useAlert(error?.response?.message || t('KANBAN.MESSAGES.ERROR'));
  } finally {
    isUpdatingAgents.value = false;
  }
};

// Inbox actions
const toggleInbox = inboxId => {
  const index = selectedInboxIds.value.indexOf(inboxId);
  if (index > -1) {
    selectedInboxIds.value.splice(index, 1);
  } else {
    selectedInboxIds.value.push(inboxId);
  }
};

const removeInbox = inboxId => {
  const index = selectedInboxIds.value.indexOf(inboxId);
  if (index > -1) {
    selectedInboxIds.value.splice(index, 1);
  }
};

const handleUpdateInboxes = async () => {
  isUpdatingInboxes.value = true;
  try {
    await store.dispatch('kanbanBoards/updateInboxes', {
      boardId: boardId.value,
      inboxIds: selectedInboxIds.value,
    });
    useAlert(t('KANBAN.MESSAGES.INBOXES_UPDATED'));
    await loadData();
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to update inboxes:', error);
    useAlert(error?.response?.message || t('KANBAN.MESSAGES.ERROR'));
  } finally {
    isUpdatingInboxes.value = false;
  }
};

// Delete board
const handleDeleteBoardClick = () => {
  deleteDialogRef.value?.open();
};

const handleDeleteBoardConfirm = async () => {
  isDeleting.value = true;
  try {
    await store.dispatch('kanbanBoards/delete', boardId.value);
    useAlert(t('KANBAN.MESSAGES.BOARD_DELETED'));
    router.push({ name: 'kanban_overview' });
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to delete board:', error);
    useAlert(
      error?.response?.message || t('KANBAN.MESSAGES.ERROR_DELETE_BOARD')
    );
  } finally {
    isDeleting.value = false;
  }
};

const getTaskCountForStep = stepId => {
  const allTasks = store.getters['kanbanTasks/getAllTasks'] || [];
  return allTasks.filter(task => task.step_id === stepId).length;
};
</script>

<template>
  <!-- eslint-disable vue/no-bare-strings-in-template -->
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
        <div>
          <h1 class="text-xl font-semibold text-n-slate-12">
            {{ t('KANBAN.SETTINGS.TITLE') }}
          </h1>
          <p class="text-sm text-n-slate-11">
            {{ board?.name }}
          </p>
        </div>
      </div>
      <div class="flex items-center gap-2 text-sm text-n-slate-11">
        <span>ID: {{ boardId }}</span>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="flex items-center justify-center flex-1">
      <Spinner :size="32" />
    </div>

    <!-- Content -->
    <div v-else class="flex-1 overflow-y-auto">
      <div class="max-w-4xl mx-auto px-6 py-8 space-y-8">
        <!-- Basic Info Section -->
        <section class="bg-n-surface-0 rounded-xl border border-n-weak p-6">
          <h2 class="text-lg font-semibold text-n-slate-12 mb-4">
            {{ t('KANBAN.SETTINGS.BASIC_INFO') }}
          </h2>

          <div class="space-y-4">
            <!-- Name -->
            <div>
              <label class="block text-sm font-medium text-n-slate-12 mb-2">
                {{ t('KANBAN.BOARD_NAME') }}
              </label>
              <input
                v-model="boardName"
                type="text"
                class="w-full px-3 py-2 rounded-lg bg-n-alpha-black2 text-n-slate-12 placeholder-n-slate-9 outline outline-1 outline-n-weak focus:outline-n-brand"
              />
            </div>

            <!-- Description -->
            <div>
              <label class="block text-sm font-medium text-n-slate-12 mb-2">
                {{ t('KANBAN.BOARD_DESCRIPTION') }}
              </label>
              <div class="relative">
                <textarea
                  v-model="boardDescription"
                  rows="4"
                  :maxlength="maxDescriptionLength"
                  class="w-full px-3 py-2 pb-8 rounded-lg bg-n-alpha-black2 text-n-slate-12 placeholder-n-slate-9 outline outline-1 outline-n-weak focus:outline-n-brand resize-none"
                />
                <div class="absolute bottom-2 right-2 text-xs text-n-slate-9">
                  {{ descriptionLength }} / {{ maxDescriptionLength }}
                </div>
              </div>
            </div>

            <div class="flex justify-end">
              <Button
                :label="isSaving ? 'Salvando...' : 'Salvar alterações'"
                color="blue"
                :is-loading="isSaving"
                :disabled="!boardName.trim()"
                @click="handleSaveBasicInfo"
              />
            </div>
          </div>
        </section>

        <!-- Steps Section -->
        <section class="bg-n-surface-0 rounded-xl border border-n-weak p-6">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-lg font-semibold text-n-slate-12">
              {{ t('KANBAN.STEPS.TITLE') }}
              <span class="ml-2 text-sm font-normal text-n-slate-11">
                ({{ steps.length }})
              </span>
            </h2>
            <Button
              icon="i-lucide-plus"
              :label="t('KANBAN.STEPS.ADD_STEP')"
              variant="faded"
              color="blue"
              size="sm"
              @click="handleAddStep"
            />
          </div>

          <div
            v-if="steps.length"
            class="divide-y divide-n-weak border-t border-n-weak"
          >
            <div
              v-for="step in steps"
              :key="step.id"
              class="flex items-center justify-between py-4"
            >
              <div class="flex items-center gap-3">
                <Icon
                  icon="i-lucide-grip-vertical"
                  class="size-4 text-n-slate-9 cursor-grab"
                />
                <div
                  class="w-4 h-4 rounded-full"
                  :style="{ backgroundColor: step.color }"
                />
                <div>
                  <span class="text-sm font-medium text-n-slate-12">{{
                    step.name
                  }}</span>
                  <span class="ml-2 text-xs text-n-slate-11">
                    {{ getTaskCountForStep(step.id) }}
                    {{ t('KANBAN.TASKS.TITLE').toLowerCase() }}
                  </span>
                </div>
              </div>
              <div class="flex items-center gap-2">
                <Button
                  icon="i-lucide-pencil"
                  variant="ghost"
                  color="slate"
                  size="sm"
                  @click="handleEditStep(step.id)"
                />
                <Button
                  icon="i-lucide-trash-2"
                  variant="ghost"
                  color="slate"
                  size="sm"
                  class="hover:enabled:text-n-ruby-11 hover:enabled:bg-n-ruby-2"
                  @click="handleDeleteStepClick(step.id)"
                />
              </div>
            </div>
          </div>
          <div v-else class="py-8 text-center text-n-slate-11">
            {{ t('KANBAN.STEPS.NO_STEPS') }}
          </div>
        </section>

        <!-- Agents Section -->
        <section class="bg-n-surface-0 rounded-xl border border-n-weak p-6">
          <h2 class="text-lg font-semibold text-n-slate-12 mb-4">
            {{ t('KANBAN.SETTINGS.ASSIGNED_AGENTS') }}
          </h2>

          <div class="space-y-4">
            <div class="flex flex-wrap gap-2">
              <span
                v-for="agentId in selectedAgentIds"
                :key="agentId"
                class="inline-flex items-center gap-1 px-3 py-1 text-sm bg-n-blue-3 text-n-blue-11 border border-n-blue-6 rounded-full"
              >
                {{ allAgents.find(a => a.id === agentId)?.name || 'Agent' }}
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
              <option value="">
                {{ t('KANBAN.SETTINGS.ADD_AGENT') || 'Add agent...' }}
              </option>
              <option
                v-for="agent in allAgents"
                :key="agent.id"
                :value="agent.id"
                :disabled="selectedAgentIds.includes(agent.id)"
              >
                {{ agent.name }}
              </option>
            </select>

            <div class="flex justify-end">
              <Button
                :label="isUpdatingAgents ? 'Atualizando...' : 'Atualizar'"
                color="blue"
                :is-loading="isUpdatingAgents"
                @click="handleUpdateAgents"
              />
            </div>
          </div>
        </section>

        <!-- Inboxes Section -->
        <section class="bg-n-surface-0 rounded-xl border border-n-weak p-6">
          <h2 class="text-lg font-semibold text-n-slate-12 mb-4">
            {{ t('KANBAN.SETTINGS.ASSIGNED_INBOXES') }}
          </h2>

          <div class="space-y-4">
            <div class="flex flex-wrap gap-2">
              <span
                v-for="inboxId in selectedInboxIds"
                :key="inboxId"
                class="inline-flex items-center gap-1 px-3 py-1 text-sm bg-n-teal-3 text-n-teal-11 border border-n-teal-6 rounded-full"
              >
                {{ allInboxes.find(i => i.id === inboxId)?.name || 'Inbox' }}
                <button
                  type="button"
                  class="hover:text-n-teal-12"
                  @click="removeInbox(inboxId)"
                >
                  <Icon icon="i-lucide-x" class="size-3" />
                </button>
              </span>
            </div>

            <select
              class="w-full px-3 py-2 text-sm rounded-lg bg-n-alpha-black2 text-n-slate-12 outline outline-1 outline-n-weak focus:outline-n-brand"
              @change="
                e => {
                  toggleInbox(parseInt(e.target.value));
                  e.target.value = '';
                }
              "
            >
              <option value="">
                {{ t('KANBAN.SETTINGS.ADD_INBOX') || 'Add inbox...' }}
              </option>
              <option
                v-for="inbox in allInboxes"
                :key="inbox.id"
                :value="inbox.id"
                :disabled="selectedInboxIds.includes(inbox.id)"
              >
                {{ inbox.name }}
              </option>
            </select>

            <div class="flex justify-end">
              <Button
                :label="isUpdatingInboxes ? 'Atualizando...' : 'Atualizar'"
                color="blue"
                :is-loading="isUpdatingInboxes"
                @click="handleUpdateInboxes"
              />
            </div>
          </div>
        </section>

        <!-- Automation Section -->
        <section class="bg-n-surface-0 rounded-xl border border-n-weak p-6">
          <h2 class="text-lg font-semibold text-n-slate-12 mb-4">
            {{ t('KANBAN.SETTINGS.AUTOMATION_TAB') }}
          </h2>

          <div class="space-y-4">
            <!-- Auto create task -->
            <label
              class="flex items-center justify-between py-3 border-b border-n-weak cursor-pointer"
            >
              <div>
                <span class="text-sm font-medium text-n-slate-12">
                  {{
                    t(
                      'KANBAN.SETTINGS.AUTOMATION.AUTO_CREATE_TASK_FOR_CONVERSATION'
                    )
                  }}
                </span>
                <p class="text-xs text-n-slate-11 mt-1">
                  {{
                    t('KANBAN.SETTINGS.AUTOMATION.AUTO_CREATE_TASK_DESC') ||
                    'Automatically create a task when a new conversation is created'
                  }}
                </p>
              </div>
              <input
                v-model="autoCreateTask"
                type="checkbox"
                class="w-5 h-5 rounded border-n-slate-3 text-n-brand focus:ring-n-brand"
              />
            </label>

            <!-- Sync agents -->
            <label
              class="flex items-center justify-between py-3 border-b border-n-weak cursor-pointer"
            >
              <div>
                <span class="text-sm font-medium text-n-slate-12">
                  {{
                    t(
                      'KANBAN.SETTINGS.AUTOMATION.SYNC_TASK_AND_CONVERSATION_AGENTS'
                    )
                  }}
                </span>
              </div>
              <input
                v-model="syncAgents"
                type="checkbox"
                class="w-5 h-5 rounded border-n-slate-3 text-n-brand focus:ring-n-brand"
              />
            </label>

            <!-- Auto assign -->
            <label
              class="flex items-center justify-between py-3 border-b border-n-weak cursor-pointer"
            >
              <div>
                <span class="text-sm font-medium text-n-slate-12">
                  {{
                    t('KANBAN.SETTINGS.AUTOMATION.AUTO_ASSIGN_TASK_TO_AGENT')
                  }}
                </span>
              </div>
              <input
                v-model="autoAssign"
                type="checkbox"
                class="w-5 h-5 rounded border-n-slate-3 text-n-brand focus:ring-n-brand"
              />
            </label>

            <!-- Auto resolve conversation -->
            <label
              class="flex items-center justify-between py-3 border-b border-n-weak cursor-pointer"
            >
              <div>
                <span class="text-sm font-medium text-n-slate-12">
                  {{
                    t(
                      'KANBAN.SETTINGS.AUTOMATION.AUTO_RESOLVE_CONVERSATION_ON_TASK_END'
                    )
                  }}
                </span>
              </div>
              <input
                v-model="autoResolveConversation"
                type="checkbox"
                class="w-5 h-5 rounded border-n-slate-3 text-n-brand focus:ring-n-brand"
              />
            </label>

            <!-- Auto complete task -->
            <label
              class="flex items-center justify-between py-3 cursor-pointer"
            >
              <div>
                <span class="text-sm font-medium text-n-slate-12">
                  {{
                    t(
                      'KANBAN.SETTINGS.AUTOMATION.AUTO_COMPLETE_TASK_ON_CONVERSATION_RESOLVE'
                    )
                  }}
                </span>
              </div>
              <input
                v-model="autoCompleteTask"
                type="checkbox"
                class="w-5 h-5 rounded border-n-slate-3 text-n-brand focus:ring-n-brand"
              />
            </label>

            <div class="flex justify-end pt-4">
              <Button
                :label="isSaving ? 'Salvando...' : 'Salvar automação'"
                color="blue"
                :is-loading="isSaving"
                @click="handleSaveAutomation"
              />
            </div>
          </div>
        </section>

        <!-- Danger Zone -->
        <section class="bg-n-surface-0 rounded-xl border border-n-ruby-6 p-6">
          <h2 class="text-lg font-semibold text-n-ruby-11 mb-2">
            {{ t('KANBAN.DANGER_ZONE.TITLE') || 'Danger Zone' }}
          </h2>
          <p class="text-sm text-n-slate-11 mb-4">
            {{
              t('KANBAN.DANGER_ZONE.DELETE_WARNING') ||
              'Deleting this board will permanently remove all tasks and steps. This action cannot be undone.'
            }}
          </p>
          <Button
            icon="i-lucide-trash-2"
            :label="t('KANBAN.DELETE_BOARD')"
            color="ruby"
            @click="handleDeleteBoardClick"
          />
        </section>
      </div>
    </div>

    <!-- Modals -->
    <CreateStepModal
      ref="createStepModalRef"
      :board-id="boardId"
      @created="loadData"
    />

    <EditStepModal
      v-if="editingStepId"
      ref="editStepModalRef"
      :step-id="editingStepId"
      :board-id="boardId"
      @close="editingStepId = null"
      @updated="handleStepUpdated"
      @deleted="handleStepUpdated"
    />

    <DeleteConfirmDialog
      ref="deleteStepDialogRef"
      :title="t('KANBAN.CONFIRM.DELETE_STEP')"
      :description="t('KANBAN.CONFIRM.DELETE_STEP')"
      :is-loading="isDeletingStep"
      @confirm="handleDeleteStepConfirm"
    />

    <DeleteConfirmDialog
      ref="deleteDialogRef"
      :title="t('KANBAN.CONFIRM.DELETE_BOARD')"
      :description="t('KANBAN.CONFIRM.DELETE_BOARD')"
      :is-loading="isDeleting"
      @confirm="handleDeleteBoardConfirm"
    />
  </div>
  <!-- eslint-enable vue/no-bare-strings-in-template -->
</template>

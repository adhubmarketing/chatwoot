<script setup>
import { ref, computed, onMounted } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import Button from 'dashboard/components-next/button/Button.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';
import Spinner from 'dashboard/components-next/spinner/Spinner.vue';
import BoardCard from './components/BoardCard.vue';
import TemplateSelectionModal from './components/TemplateSelectionModal.vue';
import CreateBoardModal from './components/CreateBoardModal.vue';

const store = useStore();
const { t } = useI18n();

const hasError = ref(false);
const errorMessage = ref('');
const templateModalRef = ref(null);
const createModalRef = ref(null);
const selectedTemplate = ref(null);

const boards = computed(() => store.getters['kanbanBoards/getAllBoards'] || []);
const uiFlags = computed(() => store.getters['kanbanBoards/getUIFlags'] || {});

onMounted(async () => {
  try {
    await store.dispatch('kanbanBoards/getAll');
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to load Kanban boards:', error);
    hasError.value = true;
    errorMessage.value =
      error.message || t('KANBAN.MESSAGES.ERROR_LOADING_BOARDS');
    useAlert(
      error?.response?.message || t('KANBAN.MESSAGES.ERROR_LOADING_BOARDS')
    );
  }
});

const openCreateFlow = () => {
  templateModalRef.value?.open();
};

const handleTemplateSelected = templateId => {
  selectedTemplate.value = templateId;
  createModalRef.value?.open();
};

const handleBackToTemplates = () => {
  templateModalRef.value?.open();
};

const createTemplateSteps = async (boardId, template) => {
  const stepTemplates = {
    sales: [
      { name: 'Qualificado', description: '', color: '#F59E0B' },
      { name: 'Geração de Proposta', description: '', color: '#3B82F6' },
      { name: 'Proposta Apresentada', description: '', color: '#8B5CF6' },
      { name: 'Negociação', description: '', color: '#6366F1' },
      { name: 'Fechamento', description: '', color: '#10B981' },
      { name: 'Perdida', description: '', color: '#EF4444' },
    ],
    support: [
      { name: 'Novo', description: '', color: '#6B7280' },
      { name: 'Em Progresso', description: '', color: '#3B82F6' },
      { name: 'Aguardando', description: '', color: '#F59E0B' },
      { name: 'Resolvido', description: '', color: '#10B981' },
    ],
    recruitment: [
      { name: 'Candidatura', description: '', color: '#6B7280' },
      { name: 'Triagem', description: '', color: '#3B82F6' },
      { name: 'Entrevista', description: '', color: '#8B5CF6' },
      { name: 'Oferta', description: '', color: '#F59E0B' },
      { name: 'Contratado', description: '', color: '#10B981' },
      { name: 'Rejeitado', description: '', color: '#EF4444' },
    ],
  };

  const steps = stepTemplates[template] || [];

  await Promise.all(
    steps.map(async step => {
      try {
        await store.dispatch('kanbanSteps/create', {
          boardId: boardId,
          stepData: step,
        });
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error('Failed to create step:', error);
        useAlert(
          error?.response?.message || t('KANBAN.MESSAGES.ERROR_CREATE_STEP')
        );
      }
    })
  );
};

const handleBoardCreated = async boardData => {
  try {
    const board = await store.dispatch('kanbanBoards/create', {
      name: boardData.name,
      description: boardData.description,
      settings: {},
    });

    // Create steps based on template
    if (boardData.template && boardData.template !== 'empty') {
      await createTemplateSteps(board.id, boardData.template);
    }

    createModalRef.value?.close();
    selectedTemplate.value = null;
    await store.dispatch('kanbanBoards/getAll');
    useAlert(t('KANBAN.MESSAGES.BOARD_CREATED'));
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to create board:', error);
    useAlert(
      error?.response?.message || t('KANBAN.MESSAGES.ERROR_CREATE_BOARD')
    );
  }
};
</script>

<template>
  <div class="flex flex-col h-full bg-n-background">
    <!-- Header -->
    <div
      class="flex items-center justify-between px-6 py-4 lg:px-16 border-b border-n-weak"
    >
      <h1 class="text-2xl font-semibold text-n-slate-12">
        {{ t('KANBAN.BOARDS') }}
      </h1>
      <div class="flex items-center gap-3">
        <Button icon="i-lucide-settings" variant="ghost" color="slate" />
        <Button
          icon="i-lucide-plus"
          :label="t('KANBAN.ADD_BOARD')"
          color="blue"
          @click="openCreateFlow"
        />
      </div>
    </div>

    <!-- Error State -->
    <div
      v-if="hasError"
      class="flex flex-col items-center justify-center flex-1 p-20"
    >
      <Icon icon="i-lucide-alert-triangle" class="size-16 text-n-amber-9" />
      <h3 class="mt-4 text-lg font-medium text-n-slate-12">
        {{ t('KANBAN.MESSAGES.ERROR') }}
      </h3>
      <p class="mt-2 text-sm text-n-slate-11">
        {{ errorMessage }}
      </p>
    </div>

    <!-- Loading State -->
    <div
      v-else-if="uiFlags.isFetching"
      class="flex items-center justify-center flex-1 p-20"
    >
      <Spinner :size="32" />
    </div>

    <!-- Empty State -->
    <div
      v-else-if="!boards || boards.length === 0"
      class="flex flex-col items-center justify-center flex-1 p-20"
    >
      <div
        class="w-20 h-20 flex items-center justify-center rounded-full bg-n-slate-3 mb-4"
      >
        <Icon icon="i-lucide-kanban" class="size-10 text-n-slate-9" />
      </div>
      <h3 class="text-lg font-medium text-n-slate-12">
        {{ t('KANBAN.NO_BOARDS') }}
      </h3>
      <p class="mt-2 text-sm text-n-slate-11 text-center max-w-md">
        {{ t('KANBAN.NO_BOARDS') }}
      </p>
      <Button
        icon="i-lucide-plus"
        :label="t('KANBAN.ADD_BOARD')"
        color="blue"
        class="mt-6"
        @click="openCreateFlow"
      />
    </div>

    <!-- Boards List -->
    <div v-else class="flex-1 overflow-y-auto px-6 py-8 lg:px-16">
      <div class="flex flex-col gap-4 max-w-7xl mx-auto">
        <BoardCard v-for="board in boards" :key="board.id" :board="board" />
      </div>
    </div>

    <!-- Modals -->
    <TemplateSelectionModal
      ref="templateModalRef"
      @select="handleTemplateSelected"
    />

    <CreateBoardModal
      ref="createModalRef"
      :selected-template="selectedTemplate"
      @back="handleBackToTemplates"
      @create="handleBoardCreated"
    />
  </div>
</template>

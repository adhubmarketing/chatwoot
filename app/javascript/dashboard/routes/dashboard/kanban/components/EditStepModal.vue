<script setup>
import { ref, computed, onMounted } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import DeleteConfirmDialog from './DeleteConfirmDialog.vue';

const props = defineProps({
  stepId: {
    type: Number,
    required: true,
  },
  // eslint-disable-next-line vue/no-unused-properties
  boardId: {
    type: Number,
    required: true,
  },
});

const emit = defineEmits(['close', 'updated', 'deleted']);

const store = useStore();
const { t } = useI18n();

const dialogRef = ref(null);
const deleteDialogRef = ref(null);

const stepName = ref('');
const stepDescription = ref('');
const stepColor = ref('#891CEC');
const isSubmitting = ref(false);
const isDeleting = ref(false);
const isLoading = ref(true);

const maxDescriptionLength = 120;
const descriptionLength = computed(() => stepDescription.value.length);

const canUpdate = computed(() => {
  return stepName.value.trim().length > 0 && !isSubmitting.value;
});

const loadStep = async () => {
  isLoading.value = true;
  try {
    const step = await store.dispatch('kanbanSteps/get', props.stepId);
    stepName.value = step.name || '';
    stepDescription.value = step.description || '';
    stepColor.value = step.color || '#891CEC';
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to load step:', error);
    useAlert(error?.response?.message || t('KANBAN.MESSAGES.ERROR'));
  } finally {
    isLoading.value = false;
  }
};

const open = () => {
  loadStep();
  dialogRef.value?.open();
};

const close = () => {
  dialogRef.value?.close();
  emit('close');
};

const handleUpdate = async () => {
  if (!canUpdate.value) return;

  isSubmitting.value = true;

  try {
    await store.dispatch('kanbanSteps/update', {
      id: props.stepId,
      name: stepName.value.trim(),
      description: stepDescription.value.trim(),
      color: stepColor.value,
    });

    useAlert(t('KANBAN.MESSAGES.STEP_UPDATED'));
    emit('updated');
    close();
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to update step:', error);
    useAlert(
      error?.response?.message || t('KANBAN.MESSAGES.ERROR_UPDATE_STEP')
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
    await store.dispatch('kanbanSteps/delete', props.stepId);
    useAlert(t('KANBAN.MESSAGES.STEP_DELETED'));
    deleteDialogRef.value?.close();
    emit('deleted');
    close();
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to delete step:', error);
    useAlert(
      error?.response?.message || t('KANBAN.MESSAGES.ERROR_DELETE_STEP')
    );
  } finally {
    isDeleting.value = false;
  }
};

onMounted(() => {
  open();
});

defineExpose({ open, close });
</script>

<template>
  <!-- eslint-disable vue/no-bare-strings-in-template -->
  <Dialog
    ref="dialogRef"
    type="edit"
    :title="t('KANBAN.STEPS.EDIT_STEP')"
    :show-confirm-button="false"
    :show-cancel-button="false"
    width="lg"
    @close="close"
  >
    <!-- Header with ID -->
    <template #description>
      <div class="flex items-center gap-2 text-sm text-n-slate-11">
        <span>ID: {{ stepId }}</span>
      </div>
      <!-- eslint-enable vue/no-bare-strings-in-template -->
    </template>

    <!-- Loading State -->
    <div v-if="isLoading" class="flex items-center justify-center py-8">
      <div class="text-n-slate-11">Carregando...</div>
    </div>

    <!-- Form Content -->
    <div v-else class="space-y-4">
      <!-- Name -->
      <div>
        <label class="block text-sm font-medium text-n-slate-12 mb-2">
          {{ t('KANBAN.STEPS.STEP_NAME') }}
        </label>
        <input
          v-model="stepName"
          type="text"
          :placeholder="t('KANBAN.STEPS.STEP_NAME')"
          class="w-full px-3 py-2 rounded-lg bg-n-alpha-black2 text-n-slate-12 placeholder-n-slate-9 outline outline-1 outline-n-weak focus:outline-n-brand"
        />
      </div>

      <!-- Description -->
      <div>
        <label class="block text-sm font-medium text-n-slate-12 mb-2">
          {{ t('KANBAN.STEPS.STEP_DESCRIPTION') }}
        </label>
        <div class="relative">
          <textarea
            v-model="stepDescription"
            rows="3"
            :maxlength="maxDescriptionLength"
            :placeholder="t('KANBAN.STEPS.STEP_DESCRIPTION')"
            class="w-full px-3 py-2 pb-8 rounded-lg bg-n-alpha-black2 text-n-slate-12 placeholder-n-slate-9 outline outline-1 outline-n-weak focus:outline-n-brand resize-none"
          />
          <div class="absolute bottom-2 right-2 text-xs text-n-slate-9">
            {{ descriptionLength }} / {{ maxDescriptionLength }}
          </div>
        </div>
      </div>

      <!-- Color -->
      <div>
        <label class="block text-sm font-medium text-n-slate-12 mb-2">
          {{ t('KANBAN.STEPS.STEP_COLOR') }}
        </label>
        <div class="flex items-center gap-3">
          <input
            v-model="stepColor"
            type="color"
            class="w-12 h-12 rounded-lg cursor-pointer bg-n-alpha-black2 outline outline-1 outline-n-weak"
          />
          <input
            v-model="stepColor"
            type="text"
            placeholder="#891CEC"
            class="flex-1 px-3 py-2 rounded-lg bg-n-alpha-black2 text-n-slate-12 placeholder-n-slate-9 outline outline-1 outline-n-weak focus:outline-n-brand"
          />
        </div>
      </div>
    </div>

    <!-- Footer -->
    <template #footer>
      <div class="flex items-center justify-between w-full gap-3">
        <Button
          icon="i-lucide-trash-2"
          label="Excluir"
          variant="faded"
          color="ruby"
          @click="handleDeleteClick"
        />

        <div class="flex gap-2">
          <Button
            label="Cancelar"
            variant="faded"
            color="slate"
            @click="close"
          />
          <Button
            :label="isSubmitting ? 'Atualizando...' : 'Atualizar'"
            color="blue"
            :disabled="!canUpdate"
            :is-loading="isSubmitting"
            @click="handleUpdate"
          />
        </div>
      </div>
      <!-- eslint-enable vue/no-bare-strings-in-template -->
    </template>
  </Dialog>

  <!-- Delete Confirmation -->
  <DeleteConfirmDialog
    ref="deleteDialogRef"
    :title="t('KANBAN.CONFIRM.DELETE_STEP')"
    :description="t('KANBAN.CONFIRM.DELETE_STEP')"
    :is-loading="isDeleting"
    @confirm="handleDeleteConfirm"
  />
  <!-- eslint-enable vue/no-bare-strings-in-template -->
</template>

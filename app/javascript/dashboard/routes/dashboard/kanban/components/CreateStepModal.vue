<script setup>
import { ref, computed } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  boardId: {
    type: Number,
    required: true,
  },
});

const emit = defineEmits(['close', 'created']);

const store = useStore();
const { t } = useI18n();
const dialogRef = ref(null);

const stepName = ref('');
const stepDescription = ref('');
const stepColor = ref('#3B82F6');
const isSubmitting = ref(false);

const maxDescriptionLength = 120;
const descriptionLength = computed(() => stepDescription.value.length);

const canCreate = computed(() => {
  return stepName.value.trim().length > 0 && !isSubmitting.value;
});

const resetForm = () => {
  stepName.value = '';
  stepDescription.value = '';
  stepColor.value = '#3B82F6';
};

const open = () => {
  resetForm();
  dialogRef.value?.open();
};

const close = () => {
  dialogRef.value?.close();
  emit('close');
};

const handleCreate = async () => {
  if (!canCreate.value) return;

  isSubmitting.value = true;

  try {
    await store.dispatch('kanbanSteps/create', {
      boardId: props.boardId,
      stepData: {
        name: stepName.value.trim(),
        description: stepDescription.value.trim(),
        color: stepColor.value,
      },
    });

    useAlert(t('KANBAN.MESSAGES.STEP_CREATED'));
    emit('created');
    close();
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to create step:', error);
    useAlert(
      error?.response?.message || t('KANBAN.MESSAGES.ERROR_CREATE_STEP')
    );
  } finally {
    isSubmitting.value = false;
  }
};

defineExpose({ open, close });
</script>

<template>
  <!-- eslint-disable vue/no-bare-strings-in-template -->
  <Dialog
    ref="dialogRef"
    type="edit"
    :title="t('KANBAN.STEPS.ADD_STEP')"
    :show-confirm-button="false"
    :show-cancel-button="false"
    width="lg"
    @close="close"
  >
    <div class="space-y-4">
      <!-- Name -->
      <div>
        <label class="block text-sm font-medium text-n-slate-12 mb-2">
          {{ t('KANBAN.STEPS.STEP_NAME') }}
        </label>
        <input
          v-model="stepName"
          type="text"
          :placeholder="t('KANBAN.STEPS.STEP_NAME')"
          class="w-full px-3 py-2 border rounded-lg bg-n-alpha-black2 text-n-slate-12 placeholder-n-slate-9 outline outline-1 outline-n-weak focus:outline-n-brand"
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
            class="w-full px-3 py-2 pb-8 border rounded-lg bg-n-alpha-black2 text-n-slate-12 placeholder-n-slate-9 outline outline-1 outline-n-weak focus:outline-n-brand resize-none"
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
            placeholder="#3B82F6"
            class="flex-1 px-3 py-2 rounded-lg bg-n-alpha-black2 text-n-slate-12 placeholder-n-slate-9 outline outline-1 outline-n-weak focus:outline-n-brand"
          />
        </div>
      </div>
    </div>

    <template #footer>
      <div class="flex items-center justify-end w-full gap-3">
        <Button label="Cancelar" variant="faded" color="slate" @click="close" />
        <Button
          :label="isSubmitting ? 'Criando...' : 'Criar'"
          color="blue"
          :disabled="!canCreate"
          :is-loading="isSubmitting"
          @click="handleCreate"
        />
      </div>
      <!-- eslint-enable vue/no-bare-strings-in-template -->
    </template>
  </Dialog>
  <!-- eslint-enable vue/no-bare-strings-in-template -->
</template>

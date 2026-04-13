<script setup>
import { ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  selectedTemplate: {
    type: String,
    default: 'empty',
  },
});

const emit = defineEmits(['close', 'create', 'back']);
const { t } = useI18n();

const dialogRef = ref(null);
const boardName = ref('');
const boardDescription = ref('');
const isCreating = ref(false);

const maxDescriptionLength = 120;
const descriptionLength = computed(() => boardDescription.value.length);

const canCreate = computed(() => {
  return boardName.value.trim().length > 0 && !isCreating.value;
});

const resetForm = () => {
  boardName.value = '';
  boardDescription.value = '';
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

  isCreating.value = true;

  try {
    emit('create', {
      name: boardName.value,
      description: boardDescription.value,
      template: props.selectedTemplate,
    });
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Error creating board:', error);
  } finally {
    isCreating.value = false;
  }
};

const handleBack = () => {
  close();
  emit('back');
};

defineExpose({ open, close });
</script>

<template>
  <Dialog
    ref="dialogRef"
    type="edit"
    :title="t('KANBAN.CREATE_BOARD')"
    :show-confirm-button="false"
    :show-cancel-button="false"
    width="lg"
    @close="close"
  >
    <div class="space-y-4">
      <!-- Name Field -->
      <div>
        <label class="block text-sm font-medium text-n-slate-12 mb-2">
          {{ t('KANBAN.BOARD_NAME') }}
        </label>
        <input
          v-model="boardName"
          type="text"
          :placeholder="t('KANBAN.BOARD_NAME')"
          class="w-full px-3 py-2 rounded-lg bg-n-alpha-black2 text-n-slate-12 placeholder-n-slate-9 outline outline-1 outline-n-weak focus:outline-n-brand"
        />
      </div>

      <!-- Description Field -->
      <div>
        <label class="block text-sm font-medium text-n-slate-12 mb-2">
          {{ t('KANBAN.BOARD_DESCRIPTION') }}
        </label>
        <div class="relative">
          <textarea
            v-model="boardDescription"
            :placeholder="t('KANBAN.BOARD_DESCRIPTION')"
            rows="4"
            :maxlength="maxDescriptionLength"
            class="w-full px-3 py-2 pb-8 rounded-lg bg-n-alpha-black2 text-n-slate-12 placeholder-n-slate-9 outline outline-1 outline-n-weak focus:outline-n-brand resize-none"
          />
          <div class="absolute bottom-2 right-2 text-xs text-n-slate-9">
            {{ descriptionLength }} / {{ maxDescriptionLength }}
          </div>
        </div>
      </div>
    </div>

    <template #footer>
      <div class="flex items-center justify-between w-full gap-3">
        <Button
          icon="i-lucide-arrow-left"
          label="Voltar"
          variant="ghost"
          color="slate"
          @click="handleBack"
        />
        <div class="flex gap-2">
          <Button
            label="Cancelar"
            variant="faded"
            color="slate"
            @click="close"
          />
          <Button
            :label="isCreating ? 'Criando...' : 'Criar'"
            color="blue"
            :disabled="!canCreate"
            :is-loading="isCreating"
            @click="handleCreate"
          />
        </div>
      </div>
    </template>
  </Dialog>
</template>

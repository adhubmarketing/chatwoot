<script setup>
import { ref } from 'vue';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';

const props = defineProps({
  title: {
    type: String,
    default: '',
  },
  description: {
    type: String,
    default: '',
  },
  confirmLabel: {
    type: String,
    default: '',
  },
  isLoading: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['confirm', 'close']);

const dialogRef = ref(null);

const computedTitle = () => props.title || 'Confirmar exclusão';
const computedDescription = () =>
  props.description || 'Esta ação não pode ser desfeita.';
const computedConfirmLabel = () => props.confirmLabel || 'Excluir';

const open = () => {
  dialogRef.value?.open();
};

const close = () => {
  dialogRef.value?.close();
  emit('close');
};

const handleConfirm = () => {
  emit('confirm');
};

defineExpose({ open, close });
</script>

<template>
  <Dialog
    ref="dialogRef"
    type="alert"
    :title="computedTitle()"
    :description="computedDescription()"
    :confirm-button-label="computedConfirmLabel()"
    cancel-button-label="Cancelar"
    :is-loading="isLoading"
    @confirm="handleConfirm"
    @close="close"
  />
</template>

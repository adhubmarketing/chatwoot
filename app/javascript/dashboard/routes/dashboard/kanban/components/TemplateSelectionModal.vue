<script setup>
import { ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';

const emit = defineEmits(['close', 'select']);
const { t } = useI18n();

const dialogRef = ref(null);
const selectedTemplate = ref(null);

const templates = computed(() => [
  {
    id: 'empty',
    name: t('KANBAN.TEMPLATES.EMPTY'),
    description: t('KANBAN.TEMPLATES.EMPTY_DESCRIPTION'),
    icon: 'i-lucide-clipboard',
  },
  {
    id: 'sales',
    name: t('KANBAN.TEMPLATES.SALES'),
    description: t('KANBAN.TEMPLATES.SALES_DESCRIPTION'),
    icon: 'i-lucide-target',
  },
  {
    id: 'support',
    name: t('KANBAN.TEMPLATES.SUPPORT'),
    description: t('KANBAN.TEMPLATES.SUPPORT_DESCRIPTION'),
    icon: 'i-lucide-headphones',
  },
  {
    id: 'recruitment',
    name: t('KANBAN.TEMPLATES.RECRUITMENT'),
    description: t('KANBAN.TEMPLATES.RECRUITMENT_DESCRIPTION'),
    icon: 'i-lucide-users',
  },
]);

const open = () => {
  selectedTemplate.value = null;
  dialogRef.value?.open();
};

const close = () => {
  dialogRef.value?.close();
  emit('close');
};

const selectTemplate = templateId => {
  selectedTemplate.value = templateId;
  close();
  emit('select', templateId);
};

defineExpose({ open, close });
</script>

<template>
  <Dialog
    ref="dialogRef"
    type="edit"
    :title="t('KANBAN.TEMPLATES.TITLE')"
    :show-confirm-button="false"
    :show-cancel-button="false"
    width="xl"
    @close="close"
  >
    <!-- Templates Grid -->
    <div class="grid grid-cols-2 gap-3">
      <button
        v-for="template in templates"
        :key="template.id"
        type="button"
        class="p-4 rounded-xl cursor-pointer transition-all outline outline-1 -outline-offset-1 text-left"
        :class="
          selectedTemplate === template.id
            ? 'outline-n-brand bg-n-blue-2'
            : 'outline-n-weak hover:outline-n-slate-6 hover:bg-n-alpha-1'
        "
        @click="selectTemplate(template.id)"
      >
        <div class="flex items-start gap-3">
          <div
            class="w-10 h-10 flex items-center justify-center rounded-lg bg-n-slate-3 flex-shrink-0"
          >
            <Icon :icon="template.icon" class="size-5 text-n-slate-11" />
          </div>
          <div class="flex-1 min-w-0">
            <h3 class="font-semibold text-n-slate-12 text-sm">
              {{ template.name }}
            </h3>
            <p class="text-xs text-n-slate-11 mt-1 line-clamp-2">
              {{ template.description }}
            </p>
          </div>
        </div>
      </button>
    </div>

    <template #footer>
      <div class="flex items-center justify-end w-full">
        <Button label="Cancelar" variant="faded" color="slate" @click="close" />
      </div>
    </template>
  </Dialog>
</template>

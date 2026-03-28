<script setup>
import { ref, computed, onMounted } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'dashboard/composables/useI18n';
import { useAlert } from 'dashboard/composables';

const props = defineProps({
  boardId: {
    type: Number,
    required: true,
  },
  step: {
    type: Object,
    default: null,
  },
});

const emit = defineEmits(['close', 'saved']);

const store = useStore();
const { t } = useI18n();

const name = ref('');
const description = ref('');
const color = ref('#1f93ff');
const cancelled = ref(false);
const isSubmitting = ref(false);

const isEditing = computed(() => !!props.step);

const colorPresets = [
  '#6B7280', // Gray
  '#EF4444', // Red
  '#F59E0B', // Orange
  '#10B981', // Green
  '#3B82F6', // Blue
  '#8B5CF6', // Purple
  '#EC4899', // Pink
  '#14B8A6', // Teal
];

onMounted(() => {
  if (props.step) {
    name.value = props.step.name;
    description.value = props.step.description || '';
    color.value = props.step.color;
    cancelled.value = props.step.cancelled || false;
  }
});

const handleSubmit = async () => {
  if (!name.value.trim()) {
    useAlert(t('KANBAN.STEPS.STEP_NAME') + ' is required');
    return;
  }

  // Validate hex color
  const hexPattern = /^#[0-9A-Fa-f]{6}$/;
  if (!hexPattern.test(color.value)) {
    useAlert('Invalid color format. Use #RRGGBB');
    return;
  }

  isSubmitting.value = true;

  try {
    const stepData = {
      name: name.value.trim(),
      description: description.value.trim(),
      color: color.value,
      cancelled: cancelled.value,
    };

    if (isEditing.value) {
      await store.dispatch('kanbanSteps/update', {
        id: props.step.id,
        ...stepData,
      });
      useAlert(t('KANBAN.MESSAGES.STEP_UPDATED'));
    } else {
      await store.dispatch('kanbanSteps/create', {
        boardId: props.boardId,
        stepData,
      });
      useAlert(t('KANBAN.MESSAGES.STEP_CREATED'));
    }

    emit('saved');
  } catch (error) {
    console.error('Failed to save step:', error);
    useAlert(t('KANBAN.MESSAGES.ERROR'));
  } finally {
    isSubmitting.value = false;
  }
};

const handleDelete = async () => {
  if (!props.step) return;

  if (window.confirm(t('KANBAN.CONFIRM.DELETE_STEP'))) {
    try {
      await store.dispatch('kanbanSteps/delete', props.step.id);
      useAlert(t('KANBAN.MESSAGES.STEP_DELETED'));
      emit('saved');
    } catch (error) {
      console.error('Failed to delete step:', error);
      useAlert(t('KANBAN.MESSAGES.ERROR'));
    }
  }
};

const handleClose = () => {
  emit('close');
};
</script>

<template>
  <woot-modal :show.sync="true" :on-close="handleClose">
    <div class="flex flex-col w-full max-w-lg p-6">
      <h3 class="mb-6 text-xl font-semibold text-slate-900 dark:text-slate-25">
        {{ isEditing ? t('KANBAN.STEPS.EDIT_STEP') : t('KANBAN.STEPS.ADD_STEP') }}
      </h3>

      <form @submit.prevent="handleSubmit">
        <!-- Step Name -->
        <div class="mb-4">
          <label class="block mb-2 text-sm font-medium text-slate-700 dark:text-slate-300">
            {{ t('KANBAN.STEPS.STEP_NAME') }} *
          </label>
          <input
            v-model="name"
            type="text"
            class="w-full px-3 py-2 border rounded-lg border-slate-300 dark:border-slate-600 focus:outline-none focus:ring-2 focus:ring-woot-500"
            :placeholder="t('KANBAN.STEPS.STEP_NAME')"
            required
          />
        </div>

        <!-- Step Description -->
        <div class="mb-4">
          <label class="block mb-2 text-sm font-medium text-slate-700 dark:text-slate-300">
            {{ t('KANBAN.STEPS.STEP_DESCRIPTION') }}
          </label>
          <textarea
            v-model="description"
            rows="3"
            class="w-full px-3 py-2 border rounded-lg border-slate-300 dark:border-slate-600 focus:outline-none focus:ring-2 focus:ring-woot-500"
            :placeholder="t('KANBAN.STEPS.STEP_DESCRIPTION')"
          />
        </div>

        <!-- Color Picker -->
        <div class="mb-4">
          <label class="block mb-2 text-sm font-medium text-slate-700 dark:text-slate-300">
            {{ t('KANBAN.STEPS.STEP_COLOR') }}
          </label>
          <div class="flex items-center gap-3">
            <input
              v-model="color"
              type="color"
              class="w-12 h-12 border rounded cursor-pointer border-slate-300 dark:border-slate-600"
            />
            <input
              v-model="color"
              type="text"
              class="flex-1 px-3 py-2 border rounded-lg border-slate-300 dark:border-slate-600 focus:outline-none focus:ring-2 focus:ring-woot-500"
              placeholder="#1f93ff"
              pattern="^#[0-9A-Fa-f]{6}$"
            />
          </div>
          <!-- Color Presets -->
          <div class="flex gap-2 mt-2">
            <button
              v-for="preset in colorPresets"
              :key="preset"
              type="button"
              class="w-8 h-8 border-2 rounded cursor-pointer hover:scale-110 transition-transform"
              :style="{ backgroundColor: preset }"
              :class="color === preset ? 'border-slate-900 dark:border-slate-100' : 'border-transparent'"
              @click="color = preset"
            />
          </div>
        </div>

        <!-- Cancelled Checkbox -->
        <div class="mb-6">
          <label class="flex items-center gap-2 cursor-pointer">
            <input
              v-model="cancelled"
              type="checkbox"
              class="w-4 h-4 rounded text-woot-500 focus:ring-woot-500"
            />
            <span class="text-sm text-slate-700 dark:text-slate-300">
              {{ t('KANBAN.STEPS.MARK_AS_CANCELLED') }}
            </span>
          </label>
          <p class="mt-1 text-xs text-slate-500">
            Mark this step as "Lost" or "Archived" to track cancelled tasks
          </p>
        </div>

        <!-- Actions -->
        <div class="flex justify-between gap-2">
          <woot-button
            v-if="isEditing"
            variant="clear"
            color-scheme="alert"
            icon="delete"
            @click="handleDelete"
          >
            {{ t('GENERAL_SETTINGS.DELETE') }}
          </woot-button>
          <div class="flex gap-2 ml-auto">
            <woot-button variant="clear" @click="handleClose">
              {{ t('GENERAL_SETTINGS.CANCEL') }}
            </woot-button>
            <woot-button
              type="submit"
              color-scheme="primary"
              :is-loading="isSubmitting"
              :disabled="!name.trim()"
            >
              {{ isEditing ? t('GENERAL_SETTINGS.SAVE') : t('KANBAN.STEPS.ADD_STEP') }}
            </woot-button>
          </div>
        </div>
      </form>
    </div>
  </woot-modal>
</template>

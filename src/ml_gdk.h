/* $Id$ */

#define GdkColormap_val(val) ((GdkColormap*)Pointer_val(val))
extern value Val_GdkColormap (GdkColormap *);

#define GdkColor_val(val) ((GdkColor*)Pointer_val(val))
#define Val_GdkColor Val_pointer

#define GdkRectangle_val(val) ((GdkRectangle*)Pointer_val(val))
#define Val_GdkRectangle Val_pointer

#define GdkDrawable_val(val) ((GdkDrawable*)Pointer_val(val))

#define GdkWindow_val(val) ((GdkWindow*)Pointer_val(val))
extern value Val_GdkWindow (GdkWindow *);

#define GdkPixmap_val(val) ((GdkPixmap*)Pointer_val(val))
extern value Val_GdkPixmap (GdkPixmap *);

#define GdkBitmap_val(val) ((GdkBitmap*)Pointer_val(val))
extern value Val_GdkBitmap (GdkBitmap *);

#define GdkImage_val(val) ((GdkImage*) val)

#define GdkFont_val(val) ((GdkFont*)Pointer_val(val))
extern value Val_GdkFont (GdkFont *);

#define GdkGC_val(val) ((GdkGC*)Pointer_val(val))
extern value Val_GdkGC (GdkGC *);

#define GdkEvent_val(type) (GdkEvent##type *)Pointer_val

#define GdkVisual_val(val) ((GdkVisual*) val)
#define Val_GdkVisual(visual) ((value) visual)

extern int OptFlags_GdkModifier_val (value);
extern int Flags_Event_mask_val (value);
extern lookup_info ml_table_extension_events[];
#define Extension_events_val(key) ml_lookup_to_c (ml_table_extension_events, key)

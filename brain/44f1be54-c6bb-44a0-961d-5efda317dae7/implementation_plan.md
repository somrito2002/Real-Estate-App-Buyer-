# Goal Description

Implement a comprehensive, scrollable "Filters" screen that opens when the user taps the filter icon on the Search Properties page. This screen will support both dark and light modes and contain various filter criteria such as property type, budget, bedrooms, bathrooms, area, furnishing, parking, amenities, construction status, and possession timeline.

## User Review Required

Please review the proposed structure of the `FilterScreen`. Since the design includes many interactive elements (radio buttons, checkboxes, range sliders, chips), I will implement them using Flutter's built-in widgets (like `RangeSlider`, `FilterChip`, `RadioListTile`, `CheckboxListTile`) styled to match your design.

Are there any specific dynamic behaviors you want me to mock, or is it okay if the UI manages its own internal state and just returns to the home screen when "Apply Filters" is pressed?

## Proposed Changes

### lib/filter_screen.dart

#### [NEW] `filter_screen.dart`
Create a new stateful widget `FilterScreen`.
- **App Bar**: "Filters" title with a back button and a "Clear All" text button.
- **Body**: A `SingleChildScrollView` containing:
  - **Property Type**: Groups for "Property Category" (Radio buttons), "Residential Properties" (Checkboxes), and "Commercial Properties" (Checkboxes).
  - **Budget**: A `RangeSlider` for price, quick selection chips, and an EMI info box.
  - **Bedrooms / Bathrooms**: Row of selectable circular chips.
  - **Area**: A `RangeSlider` for square footage.
  - **Furnishing / Parking**: Rows of selectable chips.
  - **Amenities**: A search text field followed by a `Wrap` of selectable amenity chips with icons.
  - **Construction Status / Possession Timeline**: Selectable chips.
- **Bottom Navigation**: A fixed bottom container with "Reset" and "Apply Filters" buttons.

### lib/home_screen.dart

#### [MODIFY] `home_screen.dart`
- In `_buildSearchTab()`, locate the filter icon (`Icons.tune`).
- Wrap the filter icon in an `IconButton` or `GestureDetector` with an `onTap` callback.
- The `onTap` callback will use `Navigator.push` to navigate to the new `FilterScreen`.

## Verification Plan

- Manually verify that tapping the filter icon opens the new `FilterScreen`.
- Ensure the `FilterScreen` layout matches the provided design in both light and dark modes.
- Verify that sliders, checkboxes, radio buttons, and chips are interactive and update their local state.
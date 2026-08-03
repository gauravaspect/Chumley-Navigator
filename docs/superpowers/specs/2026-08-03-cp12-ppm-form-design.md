# CP12 Form on PPM Job Details

Date: 2026-08-03  
Status: Approved

## Goal

Add a native Flutter **Landlord Gas Safety Record (CP12)** form to the PPM job details Forms section, with fields matching the HTML preview in `lib/screens/forms/cp12.html`.

## Decisions

- Flutter form (same UX patterns as LD / Damp / Vent)
- Opened from `PpmJobDetailPage` Forms card
- Prefill appointment number / engineer from `PpmJobTask`
- Local submit / mark complete only (no API in v1)
- Photo capture = placeholder buttons
- IV calculator simplified (meter type → apply)
- Findings / parts = stub controls

## Sections (tabs)

1. Risk & HSE  
2. Gas Safe  
3. Tightness test  
4. Pipework  
5. Appliances  
6. Evidence & sign-off  

## Files

- `lib/screens/forms/cp12_form_page.dart` (new)
- `lib/screens/job_details/ppm_job_detail_page.dart` (wire Forms)

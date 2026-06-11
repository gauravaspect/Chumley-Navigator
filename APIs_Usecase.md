1) Dashboard -> List Engineer Details , used in profile and dashboard screen to fetch detailed data of the engineer logged in
   curl --location 'https://navigator.chumley.ai/api/engineer/0Hn4G000000ChrUSAS?date_range=all_time' \
   --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhc3BlY3QtZW5naW5lZXItbW9iaWxlIiwic3ViIjoibmF2aWdhdG9yZW5naW5lZXJAYXNwZWN0LmNvLnVrIiwibmFtZSI6Im5hdmlnYXRvcmVuZ2luZWVyIiwicm9sZSI6ImVuZ2luZWVyIiwiZW5naW5lZXJfaWQiOiIwSG40RzAwMDAwMENoclVTQVMiLCJtYW5hZ2VkX2VuZ2luZWVyX2lkcyI6W10sInRyYWRlX2dyb3VwcyI6W10sInJhd190cmFkZV9ncm91cHMiOltdLCJhenVyZV9vaWQiOiI3YjUxNmZlZi00M2M2LTRiOTctYTU5Yi0wNjE0M2JiMjk1YTQiLCJpYXQiOjE3ODA3MzE3NzEsImV4cCI6MTc4MTMzNjU3MX0.G0_n48bT9vKcYKbKS7XBm_X3Iak8C6W-SBs-4XLftZs'
    Response:
   {
   "success": true,
   "data": {
   "id": "0Hn4G000000ChrUSAS",
   "name": "Aspect Test Engineer",
   "position": "",
   "overall_rating": 0,
   "photo_url": "https://chumley.file.force.com/profilephoto/005/F",
   "date_range": "all_time",
   "date_description": "All Time",
   "conversion": {
   "score": 0,
   "metrics": {
   "referrals": 31,
   "estimate_conversion": "35%",
   "reactive_estimate_ratio": "324/1834",
   "avg_converted_estimate_value": 550.31,
   "avg_monthly_job_count": 4.0,
   "converted_job_values": [
   4114.8,
   676.5,
   253.0,
   0.0,
   0.0,
   410.4,
   323.21,
   118.68,
   604.04,
   752.23,
   59.22,
   20.79,
   16.06,
   355.35
   ]
   }
   },
   "productivity": {
   "score": 0,
   "metrics": {
   "sa_attended": 1056,
   "absence_percentage": "0%",
   "epr_total": 367.08,
   "avg_site_value": "£246.77",
   "avg_job_value": 142.09,
   "late_to_site": 43,
   "sites_covered": 48,
   "reactive_job_values": [
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   -8.33,
   0.0,
   -8.33,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   285.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   -8.33,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   49.1,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   10.15,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   -8.33,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   9.0,
   0.0,
   0.0,
   97.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   100.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   32.8,
   0.0,
   86.0,
   9.5,
   -8.33,
   41.89,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   43.5,
   0.0,
   85.0,
   0.0,
   170.0,
   0.85,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   5872.5,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   153.5,
   48.15,
   302.5,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   42.35,
   0.0,
   10.15,
   42.5,
   0.0,
   -8.23,
   0.0,
   0.0,
   426.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   70.0,
   0.0,
   0.0,
   0.0,
   351.0,
   0.0,
   -12.5,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   8.77,
   17.1,
   0.0,
   0.0,
   21.6,
   341.99,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   -8.33,
   -8.33,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   96.0,
   0.0,
   48.5,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   -8.33,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   -8.33,
   0.0,
   -8.33,
   -8.33,
   0.0,
   -8.33,
   465.5,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   193.35,
   0.0,
   -8.33,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   -8.33,
   -8.33,
   0.0,
   0.0,
   0.0,
   -8.33,
   -8.33,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   63.0,
   63.0,
   95.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   38.43,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   -8.33,
   -8.33,
   0.0,
   -8.33,
   -8.33,
   0.0,
   0.0,
   0.0,
   -8.33,
   -8.33,
   0.0,
   0.0,
   -8.33,
   -8.33,
   5.29,
   -8.33,
   0.0,
   -8.33,
   -8.33,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   -8.33,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   -8.33,
   0.0,
   -8.33,
   0.0,
   0.0,
   9.0,
   10.0,
   0.0,
   4.75,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   11.2,
   0.0,
   89.6,
   0.0,
   35.0,
   8.6,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.02,
   0.0,
   21.4,
   0.0,
   53.5,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   0.0,
   0.0,
   110.0,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   -12.5,
   -12.5,
   -8.33,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   -8.33,
   -8.33,
   0.0,
   -8.33,
   0.0,
   -8.33,
   -8.33,
   -8.33,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0,
   0.0
   ],
   "monthly_epr": [
   {
   "month": "Mar",
   "value": 0,
   "label": "March",
   "current": false
   },
   {
   "month": "Apr",
   "value": 0,
   "label": "April",
   "current": false
   },
   {
   "month": "May",
   "value": 0,
   "label": "May",
   "current": false
   },
   {
   "month": "Jun",
   "value": 0,
   "label": "June",
   "current": true
   }
   ]
   }
   },
   "procedural": {
   "score": 0,
   "metrics": {
   "payment_collection": "22%",
   "tqrs": 227,
   "sent_for_office_approval": 83,
   "ld_form_completion": 33,
   "unclosed_jobs": 1644,
   "payment_collection_amount": 16159.31,
   "payment_collection_total_invoiced": 72646.15
   }
   },
   "vehicular": {
   "score": 0,
   "metrics": {
   "driving_score": 0,
   "pcn": 0,
   "vehicle_accident": 0,
   "vcr_updates": 31
   }
   },
   "c_sat": {
   "score": 20,
   "metrics": {
   "avg_review_rating": 1.0,
   "reviews_ratio": "3/1056",
   "cases": 0,
   "reviews_got_percentage": "3/56 (5%)",
   "review_star_counts": {
   "1": 3,
   "2": 0,
   "3": 0,
   "4": 0,
   "5": 0
   }
   }
   },
   "aspect": {
   "score": 0,
   "metrics": {
   "sites_covered": 48,
   "time_in_business": "N/A",
   "qualified_wts": 0,
   "skills": 0,
   "engineer_satisfaction_survey": 56.1
   }
   },
   "bio": {
   "trade": "HVAC",
   "years_of_service": 0,
   "skills": [],
   "areas_covered": [],
   "description": "",
   "rate_tier": "Tier 6",
   "address": "WC1X 0ND",
   "allocated_manager": "Pavlo Manko",
   "operating_hours": "07:00–19:00",
   "active": true
   },
   "dashboard": {
   "appointments_this_month": [
   {
   "id": "08pTl000003HREzIAO",
   "appointment_number": "SA-797340",
   "scheduled_start": "2026-06-06T11:08:00+00:00",
   "status": "Scheduled",
   "title": "J-408623 - Kirsten Sanders-47 Longman Court, Stationers Place-HP3 9RS",
   "type": "Reactive"
   },
   {
   "id": "08pTl000003I3s9IAC",
   "appointment_number": "SA-798537",
   "scheduled_start": "2026-06-06T16:00:00+00:00",
   "status": "Scheduled",
   "title": "J-409350 - Viktorija Jaskune-23 Culross Street-W1K 7HF",
   "type": "Reactive"
   },
   {
   "id": "08pTl000003GcKXIA0",
   "appointment_number": "SA-795862",
   "scheduled_start": "2026-06-10T07:00:00+00:00",
   "status": "Scheduled",
   "title": "J-407770 - David Swarbrick - Ormeley Road  - SW12 9QF",
   "type": "Reactive"
   },
   {
   "id": "08pTl000003CBqnIAG",
   "appointment_number": "SA-788012",
   "scheduled_start": "2026-06-10T07:38:00+00:00",
   "status": "Scheduled",
   "title": "J-403081 - Chris McGahan-Flat 7, 98 Gordon Road-W13 8PJ",
   "type": "Reactive"
   },
   {
   "id": "08pTl000003EhEfIAK",
   "appointment_number": "SA-792447",
   "scheduled_start": "2026-06-10T07:39:00+00:00",
   "status": "Scheduled",
   "title": "J-405719 - Zeena Saleem - Saint Albans Avenue  - W4 5JU",
   "type": "Reactive"
   },
   {
   "id": "08pTl000003FSjqIAG",
   "appointment_number": "SA-793853",
   "scheduled_start": "2026-06-10T11:00:00+00:00",
   "status": "Scheduled",
   "title": "J-406516 - Lucy  Adams -  - N1 7SH",
   "type": "Reactive"
   },
   {
   "id": "08pTl000003IgjqIAC",
   "appointment_number": "SA-799630",
   "scheduled_start": "2026-06-10T14:57:00+00:00",
   "status": "Scheduled",
   "title": "J-410115 - Carl Hamilton-Flat 1, 6 King Street Cloisters, Clifton Walk-W6 0GY",
   "type": "Reactive"
   },
   {
   "id": "08pTl000003HaVBIA0",
   "appointment_number": "SA-797634",
   "scheduled_start": "2026-06-10T15:01:00+00:00",
   "status": "Scheduled",
   "title": "J-408807 - Mohammed  Sagarwala - Irvine Avenue  - HA3 8QE",
   "type": "Reactive"
   },
   {
   "id": "08pTl000003EHk1IAG",
   "appointment_number": "SA-791653",
   "scheduled_start": "2026-06-11T07:00:00+00:00",
   "status": "Scheduled",
   "title": "J-405260 - Jonathan Graber-11 Gladwell Road-N8 9AA",
   "type": "Reactive"
   },
   {
   "id": "08pTl000003G9s1IAC",
   "appointment_number": "SA-794969",
   "scheduled_start": "2026-06-11T07:14:00+00:00",
   "status": "Scheduled",
   "title": "J-407254 - Colm Gough-99 Golborne Road-W10 5NL",
   "type": "Reactive"
   },
   {
   "id": "08pTl000003FPveIAG",
   "appointment_number": "SA-793794",
   "scheduled_start": "2026-06-11T10:59:00+00:00",
   "status": "Scheduled",
   "title": "J-406485 - Mustaf Moalin - Lever Street - EC1V 3SU",
   "type": "Reactive"
   },
   {
   "id": "08pTl000003I1VNIA0",
   "appointment_number": "SA-798445",
   "scheduled_start": "2026-06-11T11:00:00+00:00",
   "status": "Scheduled",
   "title": "J-409291 - 5 Lincoln Court Buckingham Road Hampton TW12 3JZ",
   "type": "Reactive"
   },
   {
   "id": "08pTl000003CboTIAS",
   "appointment_number": "SA-788755",
   "scheduled_start": "2026-06-12T06:59:00+00:00",
   "status": "Scheduled",
   "title": "J-403538 - Polly Web-Wilson - The Street  - DA4 9BY",
   "type": "Reactive"
   },
   {
   "id": "08pTl000003FMRWIA4",
   "appointment_number": "SA-793661",
   "scheduled_start": "2026-06-12T07:00:00+00:00",
   "status": "Scheduled",
   "title": "J-406421 - Bruno  Dos Santos - Farrimond House 6 St Marys - IG11 7PH",
   "type": "Reactive"
   },
   {
   "id": "08pTl000003HFfFIAW",
   "appointment_number": "SA-797005",
   "scheduled_start": "2026-06-12T18:33:00+00:00",
   "status": "Scheduled",
   "title": "J-408423 - Olusesan Adekoya - Calderwood Street  - SE18 6JF",
   "type": "Reactive"
   },
   {
   "id": "08pTl0000034PnhIAE",
   "appointment_number": "SA-774482",
   "scheduled_start": "2026-06-15T07:29:00+00:00",
   "status": "Scheduled",
   "title": "J-394863 - Johann David Lankes-123 Harvist Road, Flat C-NW6 6HA",
   "type": "Reactive"
   },
   {
   "id": "08pTl000003A32vIAC",
   "appointment_number": "SA-784423",
   "scheduled_start": "2026-06-15T08:01:00+00:00",
   "status": "Scheduled",
   "title": "J-400886 - Anil Sohun -  - HP2 6PG",
   "type": "Reactive"
   },
   {
   "id": "08pTl000003Htw1IAC",
   "appointment_number": "SA-798221",
   "scheduled_start": "2026-06-15T14:28:00+00:00",
   "status": "Scheduled",
   "title": "J-409148 - Gurdial Badwal - Kingsley Road  - ST9 0DJ",
   "type": "Reactive"
   },
   {
   "id": "08pTl000003BkqbIAC",
   "appointment_number": "SA-787304",
   "scheduled_start": "2026-06-17T19:50:00+00:00",
   "status": "Scheduled",
   "title": "J-402622 - Walford holding -  - CR6 9RL",
   "type": "Reactive"
   }
   ]
   },
   "performance_score": 0.0,
   "performance_breakdown": {
   "avg_job_value": 0.0,
   "avg_converted_estimate_value": 5.0,
   "absence_percentage": 13.0,
   "cases": 13.0,
   "avg_review_rating": 0.0,
   "driving_score": 0.0,
   "unclosed_jobs": 5.0
   }
   }
   }
   2) Points: Used to get the points data (total v/s current month), it also depicts the points calculation as per the other jobas and different parameters
      curl --location 'https://navigator.chumley.ai/api/engineers/0Hn4G000000ChrUSAS/points/summary?months=3' \
      --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhc3BlY3QtZW5naW5lZXItbW9iaWxlIiwic3ViIjoibmF2aWdhdG9yZW5naW5lZXJAYXNwZWN0LmNvLnVrIiwibmFtZSI6Im5hdmlnYXRvcmVuZ2luZWVyIiwicm9sZSI6ImVuZ2luZWVyIiwiZW5naW5lZXJfaWQiOiIwSG40RzAwMDAwMENoclVTQVMiLCJtYW5hZ2VkX2VuZ2luZWVyX2lkcyI6W10sInRyYWRlX2dyb3VwcyI6W10sInJhd190cmFkZV9ncm91cHMiOltdLCJhenVyZV9vaWQiOiI3YjUxNmZlZi00M2M2LTRiOTctYTU5Yi0wNjE0M2JiMjk1YTQiLCJpYXQiOjE3ODEwMjYyOTAsImV4cCI6MTc4MTYzMTA5MH0.ddgqfvfzqZr_EmCFN9rbgTkbDAPDezJt8Qlb280OGGg'
      Response:
        {

      "engineer_id": "0Hn4G000000ChrUSAS",
      "engineer_name": "Aspect Test Engineer",
      "trade_group": "HVAC",
      "months_requested": 3,
      "cumulative_total": 6859,
      "this_month_total": 2205,
      "months": [
      {
      "engineer_id": "0Hn4G000000ChrUSAS",
      "engineer_name": "Aspect Test Engineer",
      "trade_group": "HVAC",
      "date_range": "month_2026_06",
      "month_label": "June 2026",
      "trade_baseline": {
      "avg_job_value": 201.32,
      "avg_converted_estimate_value": 262.21
      },
      "total_points": 2205,
      "categories": {
      "per_job": {
      "total": 0,
      "events": [
      {
      "label": "AJV per job vs trade-group average",
      "points": 0,
      "count": 0,
      "detail": "0 of 0 reactive jobs above trade avg £201"
      },
      {
      "label": "Converted estimate per job vs trade-group average",
      "points": 0,
      "count": 0,
      "detail": "0 of 0 converted estimates above trade avg £262"
      }
      ]
      },
      "reviews": {
      "total": 0,
      "events": []
      },
      "lead_conversion": {
      "total": 0,
      "events": [
      {
      "label": "Lead conversion 0%",
      "points": 0,
      "count": 0,
      "detail": "0 of 1 leads converted"
      }
      ]
      },
      "reactive_estimates": {
      "total": 5,
      "events": [
      {
      "label": "Reactive lead estimates × 1",
      "points": 5,
      "count": 1,
      "detail": "+5 per estimate produced"
      }
      ]
      },
      "referrals": {
      "total": 0,
      "events": [
      {
      "label": "Referrals × 0",
      "points": 0,
      "count": 0,
      "detail": "£0 of referred work — 1 pt per £1"
      }
      ]
      },
      "consistency": {
      "total": 2200,
      "events": [
      {
      "label": "Full working weeks (4 of 4)",
      "points": 1200,
      "count": 4,
      "detail": "+300 per Mon–Fri week with no absence"
      },
      {
      "label": "Full calendar month no absence",
      "points": 1000,
      "detail": "Bonus +1000"
      }
      ]
      },
      "driving": {
      "total": 0,
      "events": [
      {
      "label": "Weekly driving score",
      "points": 0,
      "detail": "No Webfleet driving data for this period",
      "data_quality": "missing"
      }
      ]
      },
      "milestones": {
      "total": 0,
      "events": [
      {
      "label": "Top of trade group / Top 3",
      "points": 0,
      "detail": "Not in trade-group rankings for this period (group of 4)"
      },
      {
      "label": "3-month streak in top 10%",
      "points": 0,
      "detail": "Pending — needs 3 months of locked monthly snapshots",
      "data_quality": "pending"
      }
      ]
      }
      }
      },
      {
      "engineer_id": "0Hn4G000000ChrUSAS",
      "engineer_name": "Aspect Test Engineer",
      "trade_group": "HVAC",
      "date_range": "month_2026_05",
      "month_label": "May 2026",
      "trade_baseline": {
      "avg_job_value": 311.65,
      "avg_converted_estimate_value": 349.19
      },
      "total_points": 2225,
      "categories": {
      "per_job": {
      "total": 0,
      "events": [
      {
      "label": "AJV per job vs trade-group average",
      "points": 0,
      "count": 0,
      "detail": "0 of 0 reactive jobs above trade avg £312"
      },
      {
      "label": "Converted estimate per job vs trade-group average",
      "points": 0,
      "count": 0,
      "detail": "0 of 0 converted estimates above trade avg £349"
      }
      ]
      },
      "reviews": {
      "total": 0,
      "events": []
      },
      "lead_conversion": {
      "total": 0,
      "events": [
      {
      "label": "Lead conversion 0%",
      "points": 0,
      "count": 0,
      "detail": "0 of 5 leads converted"
      }
      ]
      },
      "reactive_estimates": {
      "total": 25,
      "events": [
      {
      "label": "Reactive lead estimates × 5",
      "points": 25,
      "count": 5,
      "detail": "+5 per estimate produced"
      }
      ]
      },
      "referrals": {
      "total": 0,
      "events": [
      {
      "label": "Referrals × 0",
      "points": 0,
      "count": 0,
      "detail": "£0 of referred work — 1 pt per £1"
      }
      ]
      },
      "consistency": {
      "total": 2200,
      "events": [
      {
      "label": "Full working weeks (4 of 4)",
      "points": 1200,
      "count": 4,
      "detail": "+300 per Mon–Fri week with no absence"
      },
      {
      "label": "Full calendar month no absence",
      "points": 1000,
      "detail": "Bonus +1000"
      }
      ]
      },
      "driving": {
      "total": 0,
      "events": [
      {
      "label": "Weekly driving score",
      "points": 0,
      "detail": "No Webfleet driving data for this period",
      "data_quality": "missing"
      }
      ]
      },
      "milestones": {
      "total": 0,
      "events": [
      {
      "label": "Top of trade group / Top 3",
      "points": 0,
      "detail": "Not in trade-group rankings for this period (group of 2)"
      },
      {
      "label": "3-month streak in top 10%",
      "points": 0,
      "detail": "Pending — needs 3 months of locked monthly snapshots",
      "data_quality": "pending"
      }
      ]
      }
      }
      },
      {
      "engineer_id": "0Hn4G000000ChrUSAS",
      "engineer_name": "Aspect Test Engineer",
      "trade_group": "HVAC",
      "date_range": "month_2026_04",
      "month_label": "April 2026",
      "trade_baseline": {
      "avg_job_value": 161.64,
      "avg_converted_estimate_value": 395.41
      },
      "total_points": 2429,
      "categories": {
      "per_job": {
      "total": 0,
      "events": [
      {
      "label": "AJV per job vs trade-group average",
      "points": 0,
      "count": 0,
      "detail": "0 of 0 reactive jobs above trade avg £162"
      },
      {
      "label": "Converted estimate per job vs trade-group average",
      "points": 0,
      "count": 0,
      "detail": "0 of 0 converted estimates above trade avg £395"
      }
      ]
      },
      "reviews": {
      "total": 0,
      "events": []
      },
      "lead_conversion": {
      "total": 495,
      "events": [
      {
      "label": "Lead conversion 50%",
      "points": 495,
      "count": 1,
      "detail": "1 of 2 leads converted"
      }
      ]
      },
      "reactive_estimates": {
      "total": 10,
      "events": [
      {
      "label": "Reactive lead estimates × 2",
      "points": 10,
      "count": 2,
      "detail": "+5 per estimate produced"
      }
      ]
      },
      "referrals": {
      "total": 24,
      "events": [
      {
      "label": "Referrals × 1",
      "points": 24,
      "count": 1,
      "detail": "£25 of referred work — 1 pt per £1"
      }
      ]
      },
      "consistency": {
      "total": 1900,
      "events": [
      {
      "label": "Full working weeks (3 of 3)",
      "points": 900,
      "count": 3,
      "detail": "+300 per Mon–Fri week with no absence"
      },
      {
      "label": "Full calendar month no absence",
      "points": 1000,
      "detail": "Bonus +1000"
      }
      ]
      },
      "driving": {
      "total": 0,
      "events": [
      {
      "label": "Weekly driving score",
      "points": 0,
      "detail": "No Webfleet driving data for this period",
      "data_quality": "missing"
      }
      ]
      },
      "milestones": {
      "total": 0,
      "events": [
      {
      "label": "Top of trade group / Top 3",
      "points": 0,
      "detail": "Not in trade-group rankings for this period (group of 4)"
      },
      {
      "label": "3-month streak in top 10%",
      "points": 0,
      "detail": "Pending — needs 3 months of locked monthly snapshots",
      "data_quality": "pending"
      }
      ]
      }
      }
      }
      ]
      }
   3) Leaderboard:  Shows a leaderboard with the points and postions of all the engineers to gamify the healthy competition
   curl --location 'https://navigator.chumley.ai/api/leaderboard' \
      --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhc3BlY3QtZW5naW5lZXItbW9iaWxlIiwic3ViIjoibmF2aWdhdG9yZW5naW5lZXJAYXNwZWN0LmNvLnVrIiwibmFtZSI6Im5hdmlnYXRvcmVuZ2luZWVyIiwicm9sZSI6ImVuZ2luZWVyIiwiZW5naW5lZXJfaWQiOiIwSG40RzAwMDAwMENoclVTQVMiLCJtYW5hZ2VkX2VuZ2luZWVyX2lkcyI6W10sInRyYWRlX2dyb3VwcyI6W10sInJhd190cmFkZV9ncm91cHMiOltdLCJhenVyZV9vaWQiOiI3YjUxNmZlZi00M2M2LTRiOTctYTU5Yi0wNjE0M2JiMjk1YTQiLCJpYXQiOjE3ODEwMjYyOTAsImV4cCI6MTc4MTYzMTA5MH0.ddgqfvfzqZr_EmCFN9rbgTkbDAPDezJt8Qlb280OGGg'
       Response:
      {
   "success": true,
      "data": [
      {
      "sa_attended": 84,
      "skimming_score": 95,
      "early_to_site": 0,
      "avg_site_value": "£361.03",
      "reviews_received_percentage": "0%",
      "buddy_theft_penalty": 10.0,
      "roi": 4.8644,
      "payment_collection_percentage": "0%",
      "revisit_low": 1,
      "postcode": "ME19 6RX",
      "revisit_high": 0,
      "rank": 1,
      "performance_breakdown": {
      "avg_review_rating": 3.8,
      "avg_converted_estimate_value": 9.0,
      "avg_job_value": 5.5,
      "absence_percentage": 3.2,
      "cases": 13.0,
      "payment_collection_percentage": 0.0,
      "driving_score": 0.0,
      "unclosed_jobs": 4.6
      },
      "vcr_updates": 0,
      "avg_review_rating": 4.0,
      "sent_for_office_approval": 0,
      "ld_form_completion": 0,
      "trade_group": "Electrical",
      "performance_score": 39.1,
      "name": "Reece Tullett (ME19)",
      "unclosed_jobs": 16,
      "avg_job_value": 334.4,
      "pcn": 7,
      "reviews_sent_percentage": "0%",
      "reviews_ratio": "4/84",
      "payment_collection": 0,
      "id": "0HnWS000000EsWn0AK",
      "skills": 18,
      "engineer_satisfaction_survey": 87.5,
      "time_in_business": "N/A",
      "availability_percentage": "0%",
      "tqrs": 81,
      "est_production": 0,
      "qualified_wts": 0,
      "estimate_conversion_raw": 88.88888888888889,
      "late_to_site": 0,
      "photo_url": "https://chumley.file.force.com/profilephoto/729WS0000021iM1/F",
      "avg_converted_estimate_value": 1139.64,
      "closed_jobs": 0,
      "cases": 0,
      "sites_covered": 66,
      "avg_monthly_job_count": 0,
      "absence_percentage": "38%",
      "revisit_medium": 1,
      "reactive_leads": 0,
      "estimate_conversion": "89%",
      "driving_score": 0,
      "referrals": 2,
      "revisit_count": 2,
      "roi_lead_count": 7,
      "epr_total": 7727.54
      },
      {
      "sa_attended": 81,
      "skimming_score": 10,
      "early_to_site": 0,
      "avg_site_value": "£698.18",
      "reviews_received_percentage": "0%",
      "buddy_theft_penalty": 0.0,
      "roi": 7.3663,
      "payment_collection_percentage": "36%",
      "revisit_low": 0,
      "postcode": "BR1 5AS",
      "revisit_high": 1,
      "rank": 2,
      "performance_breakdown": {
      "avg_review_rating": 8.5,
      "avg_converted_estimate_value": 4.6,
      "avg_job_value": 13.8,
      "absence_percentage": 9.7,
      "cases": 13.0,
      "payment_collection_percentage": 3.3,
      "driving_score": 0.0,
      "unclosed_jobs": 4.3
      },
      "vcr_updates": 0,
      "avg_review_rating": 5.0,
      "sent_for_office_approval": 0,
      "ld_form_completion": 0,
      "trade_group": "Leak Detection",
      "performance_score": 57.2,
      "name": "Ashley Flash (BR1) GC",
      "unclosed_jobs": 20,
      "avg_job_value": 573.13,
      "pcn": 7,
      "reviews_sent_percentage": "0%",
      "reviews_ratio": "4/81",
      "payment_collection": 15620.96,
      "id": "0HnWS000000FBET0A4",
      "skills": 9,
      "engineer_satisfaction_survey": 78.1,
      "time_in_business": "N/A",
      "availability_percentage": "0%",
      "tqrs": 67,
      "est_production": 0,
      "qualified_wts": 0,
      "estimate_conversion_raw": 88.23529411764706,
      "late_to_site": 0,
      "photo_url": "https://chumley.file.force.com/profilephoto/005/F",
      "avg_converted_estimate_value": 936.63,
      "closed_jobs": 0,
      "cases": 0,
      "sites_covered": 55,
      "avg_monthly_job_count": 0,
      "absence_percentage": "14%",
      "revisit_medium": 1,
      "reactive_leads": 0,
      "estimate_conversion": "88%",
      "driving_score": 0,
      "referrals": 5,
      "revisit_count": 2,
      "roi_lead_count": 14,
      "epr_total": 13589.62
      },
      {
      "sa_attended": 389,
      "skimming_score": 0,
      "early_to_site": 0,
      "avg_site_value": "£1110.02",
      "reviews_received_percentage": "0%",
      "buddy_theft_penalty": 0.0,
      "roi": 7.9485,
      "payment_collection_percentage": "61%",
      "revisit_low": 0,
      "postcode": "n19 3lf",
      "revisit_high": 0,
      "rank": 3,
      "performance_breakdown": {
      "avg_review_rating": 1.8,
      "avg_converted_estimate_value": 8.5,
      "avg_job_value": 19.2,
      "absence_percentage": 4.5,
      "cases": 5.8,
      "payment_collection_percentage": 11.7,
      "driving_score": 0.0,
      "unclosed_jobs": 2.6
      },
      "vcr_updates": 0,
      "avg_review_rating": 3.89,
      "sent_for_office_approval": 6,
      "ld_form_completion": 4,
      "trade_group": "Drainage",
      "performance_score": 54.1,
      "name": "Alex Guvenler (CM7)",
      "unclosed_jobs": 72,
      "avg_job_value": 1042.54,
      "pcn": 16,
      "reviews_sent_percentage": "0%",
      "reviews_ratio": "18/389",
      "payment_collection": 202173.16,
      "id": "0HnWS0000009St70AE",
      "skills": 18,
      "engineer_satisfaction_survey": 0,
      "time_in_business": "N/A",
      "availability_percentage": "0%",
      "tqrs": 327,
      "est_production": 0,
      "qualified_wts": 0,
      "estimate_conversion_raw": 58.92857142857143,
      "late_to_site": 0,
      "photo_url": "https://chumley.file.force.com/profilephoto/005/F",
      "avg_converted_estimate_value": 2522.39,
      "closed_jobs": 0,
      "cases": 3,
      "sites_covered": 289,
      "avg_monthly_job_count": 0,
      "absence_percentage": "33%",
      "revisit_medium": 0,
      "reactive_leads": 0,
      "estimate_conversion": "59%",
      "driving_score": 0,
      "referrals": 24,
      "revisit_count": 0,
      "roi_lead_count": 11,
      "epr_total": 116852.76
      },
   "count": 153,
   "cached": true,
   "source": "range_cache"
}
   4) My vehicle Allocation : Gets the details of vehicles allocated
      curl --location 'https://navigator.chumley.ai/api/vcr/allocations' \
      --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhc3BlY3QtZW5naW5lZXItbW9iaWxlIiwic3ViIjoibmF2aWdhdG9yZW5naW5lZXJAYXNwZWN0LmNvLnVrIiwibmFtZSI6Im5hdmlnYXRvcmVuZ2luZWVyIiwicm9sZSI6ImVuZ2luZWVyIiwiZW5naW5lZXJfaWQiOiIwSG40RzAwMDAwMENoclVTQVMiLCJtYW5hZ2VkX2VuZ2luZWVyX2lkcyI6W10sInRyYWRlX2dyb3VwcyI6W10sInJhd190cmFkZV9ncm91cHMiOltdLCJhenVyZV9vaWQiOiI3YjUxNmZlZi00M2M2LTRiOTctYTU5Yi0wNjE0M2JiMjk1YTQiLCJpYXQiOjE3ODEwMjYyOTAsImV4cCI6MTc4MTYzMTA5MH0.ddgqfvfzqZr_EmCFN9rbgTkbDAPDezJt8Qlb280OGGg'
   Response:
      {
      "data": [
      {
      "id": "a36Tl000000KIaHIAW",
      "vehicle_id": "a37WS0000037fHdYAI",
      "vehicle_name": "TEST111",
      "van_number": "000",
      "reg_no": "TEST111",
      "service_resource_id": "0Hn4G000000ChrUSAS",
      "engineer_name": "Aspect Test Engineer",
      "start_date": "2026-04-27",
      "end_date": null
      }
      ],
      "success": true
      }
   
   5) Inspection result picklist: Gives an inspection report for the last VCR form
   curl --location 'https://navigator.chumley.ai/api/vcr/inspection-results' \
      --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhc3BlY3QtZW5naW5lZXItbW9iaWxlIiwic3ViIjoibmF2aWdhdG9yZW5naW5lZXJAYXNwZWN0LmNvLnVrIiwibmFtZSI6Im5hdmlnYXRvcmVuZ2luZWVyIiwicm9sZSI6ImVuZ2luZWVyIiwiZW5naW5lZXJfaWQiOiIwSG40RzAwMDAwMENoclVTQVMiLCJtYW5hZ2VkX2VuZ2luZWVyX2lkcyI6W10sInRyYWRlX2dyb3VwcyI6W10sInJhd190cmFkZV9ncm91cHMiOltdLCJhenVyZV9vaWQiOiI3YjUxNmZlZi00M2M2LTRiOTctYTU5Yi0wNjE0M2JiMjk1YTQiLCJpYXQiOjE3ODEwMjYyOTAsImV4cCI6MTc4MTYzMTA5MH0.ddgqfvfzqZr_EmCFN9rbgTkbDAPDezJt8Qlb280OGGg'
   Response:
      {
      "data": {
      "values": [
      "No Issues",
      "Major Issues Found",
      "Minor Issues Noticed"
      ]
      },
      "success": true
      }
      6) Example photos section to give engineers idea of the images to be captured"
         curl --location 'https://navigator.chumley.ai/api/vcr/examples/front_exterior' \
         --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhc3BlY3QtZW5naW5lZXItbW9iaWxlIiwic3ViIjoibmF2aWdhdG9yZW5naW5lZXJAYXNwZWN0LmNvLnVrIiwibmFtZSI6Im5hdmlnYXRvcmVuZ2luZWVyIiwicm9sZSI6ImVuZ2luZWVyIiwiZW5naW5lZXJfaWQiOiIwSG40RzAwMDAwMENoclVTQVMiLCJtYW5hZ2VkX2VuZ2luZWVyX2lkcyI6W10sInRyYWRlX2dyb3VwcyI6W10sInJhd190cmFkZV9ncm91cHMiOltdLCJhenVyZV9vaWQiOiI3YjUxNmZlZi00M2M2LTRiOTctYTU5Yi0wNjE0M2JiMjk1YTQiLCJpYXQiOjE3ODEwMjYyOTAsImV4cCI6MTc4MTYzMTA5MH0.ddgqfvfzqZr_EmCFN9rbgTkbDAPDezJt8Qlb280OGGg'
      Response:{
         "data": {
         "images": [
         {
         "name": "External Front",
         "url": "https://storage.googleapis.com/flowing-garage-481412-p2.firebasestorage.app/vcr%20examples/External_Front.jpeg?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=firebase-adminsdk-fbsvc%40flowing-garage-481412-p2.iam.gserviceaccount.com%2F20260609%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20260609T214358Z&X-Goog-Expires=3600&X-Goog-SignedHeaders=host&X-Goog-Signature=424bf27f2c30ba09812ff55389ea08d3710fa1fdd0d74be4f2642735b4490fc1b8f3ab6e206bec6dae3a90b9af45050de260de89304bea4b7c58687ddf77819c31eeac86ad76d6e46320e86aef19d230344194ba629c5b9044f1e8fbb7c779f9113df493c1e81c0a35ddf3c4239bf1c0cd02456422600d6d8acdbe8d9a0070ac734ffc5e9ba8db9d8a80425af00cdcdeb404e4a9baf465775bf10e65d4eb03e25d4ff360d7617cf1fe62bb4e276bc45f96916441222422a932542d2d35d12a059738158831ec3b471068278eb130918ed8b1088e062a07bbe66fe8a49b742cff9d44a3882b3e5c0adba8645488a9b91d0ceeddca598baf983964afa84668fe3c"
         },
         {
         "name": "Wheels Front Left",
         "url": "https://storage.googleapis.com/flowing-garage-481412-p2.firebasestorage.app/vcr%20examples/Wheels_Front_Left.jpeg?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=firebase-adminsdk-fbsvc%40flowing-garage-481412-p2.iam.gserviceaccount.com%2F20260609%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20260609T214358Z&X-Goog-Expires=3600&X-Goog-SignedHeaders=host&X-Goog-Signature=4f3ba686156a278c5c7da2dca870be454e7d5933ed79c2aad20ec84df08fe7a69c9cfcc944f18b3f90de008b3b12c67e6526661b76128c81f3b2e001131cc4c6ab534742236649016445e7afe2160879323455d9550443cd7247c23bb22d7b25ab2d9065cb9a02adfdce5a50ec292e694607732c6c339b9e6dee6f4f510860023dac2919dc27fe2dc45ec7bee52fbcdcb4b5b765761cbe836d4e1da075120bbaa35ec6409cdc5c78d1a623799af004e2c5aad425b013599a5424b338fa47b99c45956ee8701ba9706e6372772780c4246ee17f4f755afed8accd0b3912774d0c8ed90ea2a080f57049f394706bd6dc2c70d5598b57b88e74b4b57c9f32cc4764"
         },
         {
         "name": "Wheels Front Right",
         "url": "https://storage.googleapis.com/flowing-garage-481412-p2.firebasestorage.app/vcr%20examples/Wheels_Front_Right.jpeg?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=firebase-adminsdk-fbsvc%40flowing-garage-481412-p2.iam.gserviceaccount.com%2F20260609%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20260609T214358Z&X-Goog-Expires=3600&X-Goog-SignedHeaders=host&X-Goog-Signature=1771ec8af695b025b17287b3d9631333cd1440da94c1a4b4f923fdc8dbd9141a96991a4a106e4a3a9f0c5dac347d0c9e8456b414b4241cfc0fb60579f97168f68956cd9ce2ca53e671f484f0b646cfe0ef532f72facb91c8ee0b5d86151fe3f810bec16dd706eff0120a4f3821dc23be17586b6c222064d018c1ba6b7928ea1bef0e18601e5e9d9753cbd9000f35f78c87d6b4bd596cab7c2ef24941af4cbccc90f4742e6c9b12e9b8c273ec87019ff0b58dfa27bbaf5ea95c08c015de54e04414980328dacbcb7d4c5888f0c98220131a0f22a9ec9fa32cce0d6f79186476eadeb5ecfec4954cdd77376680dc38afb38772516b702be32f4cdd9d316d237919"
         }
         ]
         },
         "success": true
         }
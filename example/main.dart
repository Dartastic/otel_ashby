// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_ashby/otel_ashby.dart';

/// Traces Ashby calls with OpenTelemetry.
///
/// `otel_ashby` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Ashby call in
/// [tracedAshby]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'ashby-example');

  // Wraps an Ashby API call in a CLIENT span.
  final ashbyId = await tracedAshby<String>(
    operation: 'candidate.create',
    invoke: () async {
      // Make the Ashby call here, then report what it returned.
      const id = 'ashby_8f3a2c';
      return const AshbyCallResult(
          value: id,
          result: AshbyResult(
              entityKind: 'candidate',
              entityId: 'entity_8f3a2c',
              candidateId: 'candidate_8f3a2c',
              applicationId: 'application_8f3a2c',
              applicationStatus: 'Active',
              applicationStage: '/',
              archiveReason: 'Archived',
              jobId: 'job_8f3a2c',
              jobStatus: 'Open',
              locationId: 'location_8f3a2c',
              sourceName: 'example',
              interviewId: 'interview_8f3a2c',
              interviewStatus: 'Confirmed',
              feedbackFormId: 'feedbackform_8f3a2c',
              feedbackRating: '1',
              offerStatus: 'Draft',
              referralBonusUsd: 1,
              statusCode: 201));
    },
  );
  OTelLog.info('tracedAshby candidate.create returned $ashbyId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAshbyInstrumentationAsync.
  await runWithoutAshbyInstrumentationAsync(
    () => tracedAshby<String>(
      operation: 'candidate.create',
      invoke: () async {
        const id = 'ashby_8f3a2c';
        return const AshbyCallResult(
            value: id,
            result: AshbyResult(
                entityKind: 'candidate',
                entityId: 'entity_8f3a2c',
                candidateId: 'candidate_8f3a2c',
                applicationId: 'application_8f3a2c',
                applicationStatus: 'Active',
                applicationStage: '/',
                archiveReason: 'Archived',
                jobId: 'job_8f3a2c',
                jobStatus: 'Open',
                locationId: 'location_8f3a2c',
                sourceName: 'example',
                interviewId: 'interview_8f3a2c',
                interviewStatus: 'Confirmed',
                feedbackFormId: 'feedbackform_8f3a2c',
                feedbackRating: '1',
                offerStatus: 'Draft',
                referralBonusUsd: 1,
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}

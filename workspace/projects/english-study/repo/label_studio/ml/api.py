            return Response(
                status=status.HTTP_501_NOT_IMPLEMENTED,
                data={'error': 'Not implemented - you must provide random=true query parameter'},
            )


@method_decorator(
    name='post',
    decorator=swagger_auto_schema(
        tags=['Machine Learning'],
        x_fern_sdk_group_name='ml',
        x_fern_sdk_method_name='predict_interactive',
        x_fern_audiences=['public'],
        operation_summary='Request Interactive Annotation',
        operation_description="""
        Send a request to the machine learning backend set up to be used for interactive preannotations to retrieve a
        predicted region based on annotator input. 
        See [set up machine learning](https://labelstud.io/guide/ml.html#Get-interactive-preannotations) for more.
        """,
        manual_parameters=[
            openapi.Parameter(
                name='id',
                type=openapi.TYPE_INTEGER,
                in_=openapi.IN_PATH,
                description='A unique integer value identifying this ML backend.',
            ),
        ],
        request_body=MLInteractiveAnnotatingRequest,
        responses={
            200: openapi.Response(description='Interactive annotation has succeeded.'),
        },
    ),
)
class MLBackendInteractiveAnnotating(APIView):
    """
    Send a request to the machine learning backend set up to be used for interactive preannotations to retrieve a
    predicted region based on annotator input.
    """

    permission_required = all_permissions.tasks_view

    def _error_response(self, message, log_function=logger.info):
        log_function(message)
        return Response({'errors': [message]}, status=status.HTTP_200_OK)

    def _get_task(self, ml_backend, validated_data):
        return generics.get_object_or_404(Task, pk=validated_data['task'], project=ml_backend.project)

    def _get_credentials(self, request, context, project):
        if flag_set('ff_back_dev_2362_project_credentials_060722_short', request.user):
            context.update(
                project_credentials_login=project.task_data_login,
                project_credentials_password=project.task_data_password,
            )
        return context

    def post(self, request, *args, **kwargs):
        """
        Send a request to the machine learning backend set up to be used for interactive preannotations to retrieve a
        predicted region based on annotator input.
        """
        ml_backend = generics.get_object_or_404(MLBackend, pk=self.kwargs['pk'])
        self.check_object_permissions(self.request, ml_backend)
        serializer = MLInteractiveAnnotatingRequest(data=request.data)
        serializer.is_valid(raise_exception=True)

        task = self._get_task(ml_backend, serializer.validated_data)
        context = self._get_credentials(request, serializer.validated_data.get('context', {}), task.project)

        result = ml_backend.interactive_annotating(task, context, user=request.user)

        return Response(
            result,
            status=status.HTTP_200_OK,
        )


@method_decorator(
    name='get',
    decorator=swagger_auto_schema(
        tags=['Machine Learning'],
        x_fern_sdk_group_name='ml',
        x_fern_sdk_method_name='list_model_versions',
        x_fern_audiences=['public'],
        operation_summary='Get model versions',
        operation_description='Get available versions of the model.',
        responses={'200': 'List of available versions.'},
    ),
)
class MLBackendVersionsAPI(generics.RetrieveAPIView):

    permission_required = all_permissions.projects_change

    def get(self, request, *args, **kwargs):
        ml_backend = generics.get_object_or_404(MLBackend, pk=self.kwargs['pk'])
        self.check_object_permissions(self.request, ml_backend)
        versions_response = ml_backend.get_versions()
        if versions_response.status_code == 200:
            result = {'versions': versions_response.response.get('versions', [])}
            return Response(data=result, status=200)
        elif versions_response.status_code == 404:
            result = {'versions': [ml_backend.model_version], 'message': 'Upgrade your ML backend version to latest.'}
            return Response(data=result, status=200)
        else:
            result = {'error': str(versions_response.error_message)}
            status_code = versions_response.status_code if versions_response.status_code > 0 else 500
            return Response(data=result, status=status_code)

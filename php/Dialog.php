<?php

namespace PhpToro\Plugins\Dialog;

class Dialog
{
    public static function alert(string $title, string $message = '', string $button = 'OK'): array
    {
        return phptoro_native_call('dialog', 'alert', json_encode([
            'title' => $title,
            'message' => $message,
            'button' => $button,
        ]));
    }

    public static function confirm(string $title, string $message = '', array $options = []): array
    {
        return phptoro_native_call('dialog', 'confirm', json_encode(array_merge([
            'title' => $title,
            'message' => $message,
        ], $options)));
    }

    public static function prompt(string $title, string $message = '', array $options = []): array
    {
        return phptoro_native_call('dialog', 'prompt', json_encode(array_merge([
            'title' => $title,
            'message' => $message,
        ], $options)));
    }

    public static function actionSheet(array $options, string $title = null, string $message = null): array
    {
        $args = ['options' => $options];
        if ($title !== null) $args['title'] = $title;
        if ($message !== null) $args['message'] = $message;
        return phptoro_native_call('dialog', 'actionSheet', json_encode($args));
    }
}

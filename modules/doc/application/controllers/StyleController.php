<?php

use Icinga\Application\Icinga;
use Icinga\Web\Controller;

class Doc_StyleController extends Controller
{
    public function fontAction()
    {
        $confFile = Icinga::app()->getApplicationDir('fonts/fontanello-ifont/config.json');
        $this->view->font = json_decode(file_get_contents($confFile));
    }
}
/**
 * @license Copyright (c) 2003-2014, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or http://ckeditor.com/license
 */

// Register a templates definition set named "default".
CKEDITOR.addTemplates( 'default', {
	// The name of sub folder which hold the shortcut preview images of the
	// templates.
	imagesPath: CKEDITOR.getUrl( CKEDITOR.plugins.getPath( 'templates' ) + 'templates/images/' ),

	// The templates definitions.
	templates: [
		{
		title: '画像のみ',
		html: '<div class="imgW">' +
			'<img class="decoded" alt="" src="../../../../../../sites/w/w/w/_/img/ckeditor/720x200.png">' +
			'</div>'
	},
		{
		title: '画像のみ×2',
		html: '<div class="imgW2 clearfix">' +
			'<div class="imgL"><img class="decoded" alt="" src="../../../../../../sites/w/w/w/_/img/ckeditor/350x200.png"></div>' +
			'<div class="imgR"><img class="decoded" alt="" src="../../../../../../sites/w/w/w/_/img/ckeditor/350x200.png"></div>' +
			'</div>'
	},
		{
		title: '画像のみ×3',
		html: '<div class="imgW3 clearfix">' +
			'<div><img class="decoded" alt="" src="../../../../../../sites/w/w/w/_/img/ckeditor/230x200.png"></div>' +
			'<div><img class="decoded" alt="" src="../../../../../../sites/w/w/w/_/img/ckeditor/230x200.png"></div>' +
			'<div><img class="decoded" alt="" src="../../../../../../sites/w/w/w/_/img/ckeditor/230x200.png"></div>' +
			'</div>'
	},
		{
		title: '画像左+テキスト',
		html: '<div class="imgTxtR clearfix">' +
			'<div><img class="decoded" alt="" src="../../../../../../sites/w/w/w/_/img/ckeditor/230x100.png"></div>' +
			'<p>画像回り込み<br>宮崎市では、納税の本来の姿として自主納税制度を推進しています。<br>自主納税制度とは、納税者の皆さんが定められた納期限までに自主的に納税することです。宮崎市では、納税の本来の姿として自主納税制度を推進しています。<br>自主納税制度とは、納税者の皆さんが定められた納期限までに自主的に納税することです。自主納税制度とは、納税者の皆さんが定められた納期限までに自主的に納税することです。<br>自主納税制度とは、納税者の皆さんが定められた納期限までに自主的に納税することです。宮崎市では、納税の本来の姿として自主納税制度を推進しています。</p>' +
			'</div>'
	},
		{
		title: '画像右+テキスト',
		html: '<div class="imgTxtL clearfix">' +
			'<div><img class="decoded" alt="" src="../../../../../../sites/w/w/w/_/img/ckeditor/230x100.png"></div>' +
			'<p>画像回り込み<br>宮崎市では、納税の本来の姿として自主納税制度を推進しています。<br>自主納税制度とは、納税者の皆さんが定められた納期限までに自主的に納税することです。宮崎市では、納税の本来の姿として自主納税制度を推進しています。<br>自主納税制度とは、納税者の皆さんが定められた納期限までに自主的に納税することです。自主納税制度とは、納税者の皆さんが定められた納期限までに自主的に納税することです。<br>自主納税制度とは、納税者の皆さんが定められた納期限までに自主的に納税することです。宮崎市では、納税の本来の姿として自主納税制度を推進しています。</p>' +
			'</div>'
	},
		{
		title: '画像×2+下テキスト',
		html: '<div class="imgW2 clearfix">' +
			'<div class="imgL">' +
			'<img class="decoded" alt="" src="../../../../../../sites/w/w/w/_/img/ckeditor/350x200.png">' +
			'<p>テキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキスト</p>' +
			'</div>' +
			'<div class="imgR">' +
			'<img class="decoded" alt="" src="../../../../../../sites/w/w/w/_/img/ckeditor/350x200.png">' +
			'<p>テキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキスト</p>' +
			'</div>' +
			'</div>'
	},
		{
		title: '画像×2+上テキスト',
		html: '<div class="imgW2 clearfix">' +
			'<div class="imgL">' +
			'<p>テキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキスト</p>' +
			'<img class="decoded" alt="" src="../../../../../../sites/w/w/w/_/img/ckeditor/350x200.png">' +
			'</div>' +
			'<div class="imgR">' +
			'<p>テキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキストテキスト</p>' +
			'<img class="decoded" alt="" src="../../../../../../sites/w/w/w/_/img/ckeditor/350x200.png">' +
			'</div>' +
			'</div>'
	},
		{
		title: '画像左+テキスト（回り込みなし）',
		html: '<div class="imgLTxtR clearfix">' +
			'<div><img class="decoded" alt="" src="../../../../../../sites/w/w/w/_/img/ckeditor/350x100.png"></div>' +
			'<p>画像回り込み<br>宮崎市では、納税の本来の姿として自主納税制度を推進しています。<br>自主納税制度とは、納税者の皆さんが定められた納期限までに自主的に納税することです。宮崎市では、納税の本来の姿として自主納税制度を推進しています。<br>自主納税制度とは、納税者の皆さんが定められた納期限までに自主的に納税することです。自主納税制度とは、納税者の皆さんが定められた納期限までに自主的に納税することです。<br>自主納税制度とは、納税者の皆さんが定められた納期限までに自主的に納税することです。宮崎市では、納税の本来の姿として自主納税制度を推進しています。</p>' +
			'</div>'
	},
		{
		title: '画像右+テキスト（回り込みなし）',
		html: '<div class="imgRTxtL clearfix">' +
			'<div><img class="decoded" alt="" src="../../../../../../sites/w/w/w/_/img/ckeditor/350x100.png"></div>' +
			'<p>画像回り込み<br>宮崎市では、納税の本来の姿として自主納税制度を推進しています。<br>自主納税制度とは、納税者の皆さんが定められた納期限までに自主的に納税することです。宮崎市では、納税の本来の姿として自主納税制度を推進しています。<br>自主納税制度とは、納税者の皆さんが定められた納期限までに自主的に納税することです。自主納税制度とは、納税者の皆さんが定められた納期限までに自主的に納税することです。<br>自主納税制度とは、納税者の皆さんが定められた納期限までに自主的に納税することです。宮崎市では、納税の本来の姿として自主納税制度を推進しています。</p>' +
			'</div>'
	},
		{
		title: '関連書類',
		html: '<div class="documents">' +
			'<div>関連書類</div>' +
			'<ul class="arrow">' +
			'<li><a href="#">書類名(00KB PDF)</a></li>' +
			'<li><a href="#">書類名(00KB PDF)</li>' +
			'</ul>' +
			'</div>'
	}
	]
} );
